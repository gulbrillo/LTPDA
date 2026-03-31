% WHITEN2D whiten the noise for two cross correlated time series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: whiten2D whitens cross-correlated time-series. Whitening
% filters are constructed by a fitting procedure to the cross-spectrum
% models provided.
% Note: The function assumes that the input model corresponds to the
% one-sided csd of the data to be whitened.
%
% ALGORITHM:
%            1) Fit a set of partial fraction z-domain filters using
%               utils.math.psd2wf
%            2) Convert to bank of mIIR filters
%            3) Filter time-series in parallel
%               The filtering process is:
%               b(1) = Filt11(a(1)) + Filt12(a(2))
%               b(2) = Filt21(a(1)) + Filt22(a(2))
%
% CALL:             b = whiten2D(a, pl) % returns whitened time-series AOs
%                   [b1,b2] = whiten2D(a1, a2, pl)
%                   [b1,b2,...,bn] = whiten2D(a1,a2,...,an, pl);
%                   Note: Input AOs must come in couples.
%                   Note: this method cannot be used as a modifier, the
%                   call a.whiten2D(pl) is forbidden.
%
% INPUT:
%
%               - a is a couple of two colored noise time-series AOs
%
% OUTPUT:
%
%               - b is a couple of "whitened" time-series AOs. The whitening
%               filters used are stored in the objects procinfo field under
%               the parameters:
%                 - b(1): 'Filt11' and 'Filt12'
%                 - b(2): 'Filt21' and 'Filt22'
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'whiten2D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = whiten2D(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  cs = copy(as, nargout);
  inhists = [as.hist];
  
  % This PLIST key is only necessary for rebuilding the object
  rebuildHistory = 'REBUILD:HISTORY';
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl, {rebuildHistory});
  pl.getSetRandState();
  
  
  % Extract necessary model parameters
  csd11 = find_core(pl, 'csd11');
  csd12 = find_core(pl, 'csd12');
  csd21 = find_core(pl, 'csd21');
  csd22 = find_core(pl, 'csd22');
  
  if nargout == 0
    error('### noisegen2D cannot be used as a modifier. Please give an output variable.');
  end
  
  % Check the number of input AO
  if numel(bs)==1
    error('!!! One input AO! The input AOs must come in pairs!');
  end
  % Checks that the input AOs come in pairs
  odc = 0;
  if rem(numel(as),2)
    warning('The input AOs must come in pairs! Skipping AO %s during calculation', ao_invars{end});
    odc = 1;
  end
  
  % Loop over input AOs to check for non time series objects
  fsv = zeros(numel(bs),1);
  for jj=1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      error('!!! %s expects ao/tsdata objects. ', mfilename);
    end
    fsv(jj,1) = bs(jj).data.fs; % collecting sampling frequencies
  end
  % Check that input Aos have the same sampling frequency
  if any(diff(fsv))
    error('!!! Sampling frequency must be the same for all input objects')
  end
  
  % ------------------- Coloring Noise
  
  % ----------------------------------
  % 1) - Fitting the models to identify the innovation filters
  
  % Build input structure for psd2tf
  params = struct();
  
  params.idtp = 1;
  params.Nmaxiter = find_core(pl, 'MaxIter');
  params.minorder = find_core(pl, 'MinOrder');
  params.maxorder = find_core(pl, 'MaxOrder');
  params.spolesopt = find_core(pl, 'PoleType');
  params.weightparam = find_core(pl, 'Weights');
  params.usesym = find_core(pl, 'UseSym');
  params.spy = find_core(pl, 'Disp');
  params.keepvar = find_core(pl, 'keepvar');
  
  % Tolerance for MSE Value
  lrscond = find_core(pl, 'FITTOL');
  % give an error for strange values of lrscond
  if lrscond<0
    error('!!! Negative values for FITTOL are not allowed !!!')
  end
  % handling data
  lrscond = -1*log10(lrscond);
  % give a warning for strange values of lrscond
  if lrscond<0
    warning('You are searching for a MSE lower than %s', num2str(10^(-1*lrscond)))
  end
  params.lrscond = lrscond;
  
  % Tolerance for the MSE relative variation
  msevar = find_core(pl, 'MSEVARTOL');
  % handling data
  msevar = -1*log10(msevar);
  % give a warning for strange values of msevar
  if msevar<0
    warning('You are searching for MSE relative variation lower than %s', num2str(10^(-1*msevar)))
  end
  params.msevar = msevar;
  
  if isempty(params.msevar)
    params.ctp = 'chival';
  else
    params.ctp = 'chivar';
  end
  
  if(find_core(pl, 'plot'))
    params.plot = 1;
  else
    params.plot = 0;
  end
  
  params.fs = fsv(1,1);
  params.dterm = 0;
  
  % get data variance
  vars = [1 1];
  if numel(bs)==2
    for ii=1:numel(bs)
      b = bs(ii).y;
      v = var(b);
      vars(ii) = v;
    end
  end
  params.vars = vars;
  
  % call psd2wf
  ostruct = utils.math.psd2wf(csd11.y,csd12.y,csd21.y,csd22.y,csd11.x,params);
  
  % ----------------------------------
  % 2) - Convert into MIIR filters
  
  fs = fsv(1,1);
  
  % --- filter 1 ---
  res = ostruct(1).res;
  poles = ostruct(1).poles;
  dterm = ostruct(1).dterm;
  % construct a struct array of miir filters vectors
  pfilts1 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    pfilts1 = [pfilts1 ft];
  end
  %   pfilts1 = [pfilts1 miir(dterm, [1 0], fs)];
  
  % --- filter 2 ---
  res = ostruct(2).res;
  poles = ostruct(2).poles;
  dterm = ostruct(2).dterm;
  % construct a struct array of miir filters vectors
  pfilts2 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    pfilts2 = [pfilts2 ft];
  end
  %   pfilts2 = [pfilts2 miir(dterm, [1 0], fs)];
  
  % --- filter 3 ---
  res = ostruct(3).res;
  poles = ostruct(3).poles;
  dterm = ostruct(3).dterm;
  % construct a struct array of miir filters vectors
  pfilts3 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    pfilts3 = [pfilts3 ft];
  end
  %   pfilts3 = [pfilts3 miir(dterm, [1 0], fs)];
  
  % --- filter 4 ---
  res = ostruct(4).res;
  poles = ostruct(4).poles;
  dterm = ostruct(4).dterm;
  % construct a struct array of miir filters vectors
  pfilts4 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    pfilts4 = [pfilts4 ft];
  end
  %   pfilts4 = [pfilts4 miir(dterm, [1 0], fs)];
  
  % ----------------------------------
  % 3) Filtering data
  
  for jj = 1:2:numel(bs)-1-odc
    
    bs(jj) = filter(cs(jj), pfilts1) + filter(cs(jj+1), pfilts2);
    bs(jj+1) = filter(cs(jj), pfilts3) + filter(cs(jj+1), pfilts4);
    
    % -----------------------------------
    % 4) Output data
    
    % name for this object
    bs(jj).name = sprintf('whiten2D(%s)_c1', [ao_invars{jj} ao_invars{jj+1}]);
    bs(jj+1).name = sprintf('whiten2D(%s)_c2', [ao_invars{jj} ao_invars{jj+1}]);
    % Collect the filters into procinfo
    bs(jj).procinfo = combine(plist('Filt11', pfilts1,'Filt12', pfilts2),as(jj).procinfo);
    bs(jj+1).procinfo = combine(plist('Filt21', pfilts3,'Filt22', pfilts4),as(jj+1).procinfo);
    % add history
    if pl.isparam(rebuildHistory) && ~pl.find_core(rebuildHistory)
      % We are in a rebuild step.
      % Don't add history for the second object because the first
      % object have already rebuild the objects.
    else
      bs(jj).addHistory(getInfo('None'), pl.pset(rebuildHistory, true), ao_invars(jj:jj+1), inhists(jj:jj+1));
      bs(jj+1).addHistory(getInfo('None'), pl.pset(rebuildHistory, false), ao_invars(jj:jj+1), inhists(jj:jj+1));
    end
    
  end
  
  % clear errors
  bs.clearErrors;
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs.index(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setArgsmin(2);
  ii.setOutmin(2);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % CSD11
  p = param({'csd11', 'A frequency-series AO describing the model csd11'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % CSD12
  p = param({'csd12', 'A frequency-series AO describing the model csd12'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % CSD21
  p = param({'csd21', 'A frequency-series AO describing the model csd21'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % CSD22
  p = param({'csd22', 'A frequency-series AO describing the model csd22'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % MaxIter
  p = param({'MaxIter', 'Maximum number of iterations in fit routine.'}, paramValue.DOUBLE_VALUE(30));
  pl.append(p);
  
  % PoleType
  p = param({'PoleType', ['Choose the pole type for fitting:<ol>'...
    '<li>use real starting poles</li>' ...
    '<li>generates complex conjugate poles of the<br>'...
    'type <tt>a.*exp(theta*pi*j)</tt><br>'...
    'with <tt>theta = linspace(0,pi,N/2+1)</tt></li>'...
    '<li>generates complex conjugate poles of the type<br>'...
    '<tt>a.*exp(theta*pi*j)</tt><br>'...
    'with <tt>theta = linspace(0,pi,N/2+2)</tt></li></ol>']}, {3, {1,2,3}, paramValue.SINGLE});
  pl.append(p);
  
  % MinOrder
  p = param({'MinOrder', 'Minimum order to fit with.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % MaxOrder
  p = param({'MaxOrder', 'Maximum order to fit with.'}, paramValue.DOUBLE_VALUE(25));
  pl.append(p);
  
  % Weights
  p = param({'Weights', ['Choose weighting for the fit:<ol>'...
    '<li>equal weights for each point</li>'...
    '<li>weight with <tt>1/abs(model)</tt></li>'...
    '<li>weight with <tt>1/abs(model).^2</tt></li>'...
    '<li>weight with inverse of the square mean spread<br>'...
    'of the model</li></ol>']}, paramValue.DOUBLE_VALUE(3));
  pl.append(p);
  
  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Disp
  p = param({'Disp', 'Display the progress of the fitting iteration.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % MSEVARTOL
  p = param({'MSEVARTOL', ['Mean Squared Error Variation - Check if the<br>'...
    'realtive variation of the mean squared error is<br>'...
    'smaller than the value specified. This<br>'...
    'option is useful for finding the minimum of Chi-squared.']}, ...
    paramValue.DOUBLE_VALUE(1e-2));
  pl.append(p);
  
  % FITTOL
  p = param({'FITTOL', ['Mean Squared Error Value - Check if the mean<br>'...
    'squared error value is lower than the value<br>'...
    'specified.']}, paramValue.DOUBLE_VALUE(1e-2));
  pl.append(p);
  
  % UseSym
  p = param({'UseSym', ['Use symbolic calculation in eigen-decomposition.<ul>'...
    '<li>0 - perform double-precision calculation in the<br>'...
    'eigendecomposition procedure to identify 2-Dim<br>'...
    'systems and for poles stabilization</li>'...
    '<li>1 - uses symbolic math toolbox variable precision<br>'...
    'arithmetic in the eigen-decomposition for 2-Dim<br>'...
    'system identification and double-precison for<br>'...
    'poles stabilization</li>'...
    '<li>2 - uses symbolic math toolbox variable precision<br>'...
    'arithmetic in the eigen-decomposition for 2-Dim<br>'...
    'system identification and for poles stabilization.']}, {1, {0,1,2}, paramValue.SINGLE});
  pl.append(p);
  
  % Keep var
  p = param({'keepvar', '???'}, paramValue.TRUE_FALSE);
  p.val.setValIndex(2);
  pl.append(p);
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
end


% PARAMETERS:
%
%          'csd11'   - a frequency-series AO describing the model csd11
%          'csd12'   - a frequency-series AO describing the model csd12
%          'csd21'   - a frequency-series AO describing the model csd21
%          'csd22'   - a frequency-series AO describing the model csd22
%
%          'MaxIter' - Maximum number of iterations in fit routine
%                      [default: 30]
%
%          'PoleType' - Choose the pole type for fitting:
%                       1  - use real starting poles
%                       2  - generates complex conjugate poles of the
%                            type a.*exp(theta*pi*j)
%                            with theta = linspace(0,pi,N/2+1)
%                       3  - generates complex conjugate poles of the type
%                            a.*exp(theta*pi*j)
%                            with theta = linspace(0,pi,N/2+2) [default]
%
%          'MinOrder' - Minimum order to fit with. [default: 2]
%
%          'MaxOrder' - Maximum order to fit with. [default: 25]
%
%          'Weights'  - choose weighting for the fit: [default: 2]
%                       1  - equal weights for each point
%                       2  - weight with 1/abs(model)
%                       3  - weight with 1/sqrt(abs(model))
%                       4  - weight with inverse of the square mean spread
%                            of the model
%
%          'Plot'     - plot results of each fitting step. [default: false]
%
%          'Disp'     - Display the progress of the fitting iteration.
%                       [default: false]
%
%          'FITTOL'   - Mean Squared Error Value - Check if the mean
%                       squared error value is lower than the value
%                       specified. [defalut: 1e-2]
%
%         'MSEVARTOL' - Mean Squared Error Variation - Check if the
%                       realtive variation of the mean squared error is
%                       smaller than the value specified. This
%                       option is useful for finding the minimum of Chi
%                       squared. [default: 1e-2]]
%
%          'UseSym'   - Use symbolic calculation in eigendecomposition.
%                       [default: 0]
%                       0 - perform double-precision calculation in the
%                           eigendecomposition procedure to identify 2dim
%                           systems and for poles stabilization
%                       1 - uses symbolic math toolbox variable precision
%                           arithmetic in the eigendecomposition for 2dim
%                           system identification and double-precison for
%                           poles stabilization
%                       2 - uses symbolic math toolbox variable precision
%                           arithmetic in the eigendecomposition for 2dim
%                           system identification and for poles
%                           stabilization
