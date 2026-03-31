% NOISEGEN2D generates cross correleted colored noise from white noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: noisegen2D can work in two different modes:
%
% ------------------------------------------------------------------------
%
% 1) Generates colored noise from white noise with a given cross spectrum.
%     This mode correspond to the 'Default' set for the method (see the
%     list of parameters).
%
%   The coloring filter is constructed by a fitting procedure to the models
%   provided. If no model is provided an error is prompted. The
%   cross-spectral matrix is assumed to be frequency by frequency of the
%   type:
%
%                         / csd11(f)  csd12(f) \
%               CSD(f) =  |                    |
%                         \ csd21(f)  csd22(f) /
%
%              Note: The function output colored noise data with one-sided
%              csd corresponding to the model provided.
%
% ALGORITHM:
%            1) Fit a set of partial fraction z-domain filters
%            2) Convert to array of MIIR filters
%            3) Filter time-series in parallel
%               The filtering process is:
%               b(1) = Filt11(a(1)) + Filt12(a(2))
%               b(2) = Filt21(a(1)) + Filt22(a(2))
%
%
% CALL:             b = noisegen2D(a, pl) % returns colored time-series AOs
%                   b = noisegen2D(a, pl)
%                   [b1,b2] = noisegen2D(a1, a2, pl)
%                   [b1,b2,...,bn] = noisegen2D(a1,a2,...,an, pl);
%                   Note: this method cannot be used as a modifier, the
%                   call a.noisegen2D(pl) is forbidden
%
% INPUT:
%
%               - a is at least a couple of time series analysis objects
%               - pl is a parameter list, see the list of accepted
%               parameters below
%
% OUTPUT:
%
%               - b are a couple of colored time-series AOs. The coloring
%               filters used are stored in the objects procinfo field under
%               the parameters:
%                 - b(1): 'Filt11' and 'Filt12'
%                 - b(2): 'Filt21' and 'Filt22'
% ------------------------------------------------------------------------
%
% 2) Generates coloring filter
%     This mode correspond to the 'Filter' set for the method (see the
%     list of parameters).
%
%   The coloring filter is constructed by a fitting procedure to the models
%   provided. The cross-spectral matrix is assumed to be frequency by
%   frequency of the type:
%
%                         / csd11(f)  csd12(f) \
%               CSD(f) =  |                    |
%                         \ csd21(f)  csd22(f) /
%
% ALGORITHM:
%            1) Fit a set of partial fraction z-domain filters
%            2) Convert to array of MIIR filters
%
%
% CALL:             fil = noisegen2D(csd11,csd12,csd21,csd22, pl)
%                   fil = noisegen2D(csd11,csd12,csd22, pl)
%                   Note: this method cannot be used as a modifier, the
%                   call a.noisegen2D(pl) is forbidden
%
% INPUT:
%
%               - csd11, csd12, csd21,csd22 are the terms of the
%               cross-spectral matrix. They must be frequency series
%               analysis objects.
%               - pl is a parameter list, see the list of accepted
%               parameters below
%
% OUTPUT:
%
%               - fil is a matrix object which represent a two dimensional
%               filter. The elements of fil are filterbanks parallel
%               objects of miir filters. Filters are initialized to
%               avoid startup transients.
%
% ------------------------------------------------------------------------
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'noisegen2D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = noisegen2D(varargin)
  
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
  inhists = [as.hist];
  
  % combine plists
  % define input/output combinations. Different combination are
  % 1) input tsdata and csd# into the plist, output are colored tsdata
  % 2) input fsdata, output is a coloring filter (in a matrix)
  if isempty(pl) % no model input, get model from input
    setpar = 'Filter';
  elseif numel(as)==3 && isa(as(1).data,'fsdata') % get model from input
    setpar = 'Filter';
  elseif numel(as)==4 && isa(as(1).data,'fsdata') % get model from input
    setpar = 'Filter';
  else % get model from plist, output tsdata, back compatibility mode
    setpar = 'Default';
  end
  
  % This PLIST key is only necessary for rebuilding the object
  rebuildHistory = 'REBUILD:HISTORY';
  
  pl = applyDefaults(getDefaultPlist(setpar), pl, {rebuildHistory});
  pl.getSetRandState();
  
  if nargout == 0
    error('### noisegen2D cannot be used as a modifier. Please give an output variable.');
  end
  
  % Check the number of input AOs
  if numel(bs)==1
    error('!!! One input AO! At least two independent white noise time series or three frequency series are needed');
  end
  
  switch lower(setpar)
    case 'default' % back compatibility mode
      
      % this copy will be used for data filtering
      cs = copy(as, nargout);
      
      % Extract necessary model parameters
      csd11 = find_core(pl, 'csd11');
      csd12 = find_core(pl, 'csd12');
      csd21 = find_core(pl, 'csd21');
      csd22 = find_core(pl, 'csd22');
      
      if ~isempty(csd12) && isempty(csd21)
        csd21 = conj(csd12);
      elseif ~isempty(csd21) && isempty(csd12)
        csd12 = conj(csd21);
      elseif isempty(csd12) && isempty(csd21)
        error('!!! One of the parameters ''csd12'' or ''csd21'' must be not empty!')
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
        fsv(jj,1) = bs(jj).fs; % collecting sampling frequencies
      end
      % Check that input Aos have the same sampling frequency
      if any(diff(fsv))
        error('!!! Sampling frequency must be the same for all input objects')
      end
      
    case 'filter'
      
      % get models from inputs
      if numel(bs)==3
        csd11 = bs(1);
        csd12 = bs(2);
        csd21 = conj(csd12);
        csd22 = bs(3);
      elseif numel(bs)==2
        error('!!! A number of fsdata ao between 3 and 4 must be given as input')
      else
        csd11 = bs(1);
        csd12 = bs(2);
        csd21 = bs(3);
        csd22 = bs(4);
      end
      
      fsv    = find_core(pl,'fs');
      Iunits = find_core(pl, 'Iunits');
      Ounits = find_core(pl, 'Ounits');
      
    otherwise
      
      error('!!! Something with the input is going wrong! Check function help for details on how input data properly')
      
  end
  
  
  % ----------------------------------
  % 1) - Fitting the models to identify the innovation filters
  
  % Build input structure for psd2tf
  params = struct();
  
  params.idtp = 1;
  params.Nmaxiter = find_core(pl, 'MaxIter');
  params.minorder = find_core(pl, 'MinOrder');
  params.maxorder = find_core(pl, 'MaxOrder');
  params.spolesopt = find_core(pl, 'PoleType');
  params.usesym = find_core(pl, 'UseSym');
  params.spy = find_core(pl, 'Disp');
  
  % check for weights
  wobj = find_core(pl, 'Weights');
  if isa(wobj,'ao')
    warning('Using externally provided weights.')
    params.weightparam = 0;
    % check external weights dimensions
    if numel(wobj)~= 4
      error('!!! Provide a weight for each CSD element')
    end
    for ii=1:4
      twobj = wobj.index(ii).y;
      % willing to work with columns
      [aaw,bbw] = size(twobj);
      if aaw<bbw
        twobj = twobj.';
      end
      wobj2(:,ii) = twobj;
    end
    params.extweights = wobj2;
  else
    params.weightparam = wobj;
  end
  
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
  params.dterm = 0; % it is better to fit without direct term
  
  % call psd2tf
  ostruct = utils.math.psd2tf(csd11.y,csd12.y,csd21.y,csd22.y,csd11.x,params);
  
  % ----------------------------------
  % 2) - Convert into MIIR filters
  
  fs = fsv(1,1);
  
  % get init states for coloring filters
  mres13 = [ostruct(1).res ostruct(3).res];
  mres24 = [ostruct(2).res ostruct(4).res];
  mpoles13 = [ostruct(1).poles ostruct(3).poles];
  mpoles24 = [ostruct(4).poles ostruct(4).poles];
  
  % initialize filters to cope with starting transients
  %   Zi1 = zeros(numel(mres13(:,1)),1);
  %   Zi3 = Zi1;
  
  Zi = utils.math.getinitstate(mres13,mpoles13,1,'mtd','svd');
  Zi1 = Zi(1:numel(mres13(:,1)));
  Zi3 = Zi(numel(mres13(:,1))+1:2*numel(mres13(:,1)));
  
  %   Zi2 = zeros(numel(mres24(:,1)),1);
  %   Zi4 = Zi2;
  
  Zi = utils.math.getinitstate(mres24,mpoles24,1,'mtd','svd');
  Zi2 = Zi(1:numel(mres24(:,1)));
  Zi4 = Zi(numel(mres24(:,1))+1:2*numel(mres24(:,1)));
  
  % --- filter 1 ---
  res = mres13(:,1);
  poles = mpoles13(:,1);
  % construct a struct array of miir filters vectors
  pfilts1 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    ft.setHistout(Zi1(kk));
    pfilts1 = [pfilts1 ft];
  end
  
  % --- filter 2 ---
  res = mres24(:,1);
  poles = mpoles24(:,1);
  % construct a struct array of miir filters vectors
  pfilts2 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    ft.setHistout(Zi2(kk));
    pfilts2 = [pfilts2 ft];
  end
  
  % --- filter 3 ---
  res = mres13(:,2);
  poles = mpoles13(:,2);
  % construct a struct array of miir filters vectors
  pfilts3 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    ft.setHistout(Zi3(kk));
    pfilts3 = [pfilts3 ft];
  end
  
  % --- filter 4 ---
  res = mres24(:,2);
  poles = mpoles24(:,2);
  % construct a struct array of miir filters vectors
  pfilts4 = [];
  for kk=1:numel(res)
    ft = miir(res(kk), [ 1 -poles(kk)], fs);
    ft.setHistout(Zi4(kk));
    pfilts4 = [pfilts4 ft];
  end
  
  % switch between output options
  switch lower(setpar)
    case 'default'
      % ----------------------------------
      % 3) Filtering data
      
      for jj = 1:2:numel(bs)-1-odc
        
        % add yunits, taking them from plist or, if empty, from input objects
        Iunits1 = bs(jj).yunits;
        Iunits2 = bs(jj+1).yunits;
        Ounits = find_core(pl, 'yunits');
        switch class(Ounits)
          case 'cell'
            Ounits1 = Ounits{1};
            Ounits2 = Ounits{2};
          case 'unit'
            Ounits1 = Ounits(1);
            Ounits2 = Ounits(2);
          otherwise
            error('### Bad format for unit container. Supporting vector or cell array');
        end
        if isequal(unit(Ounits1), unit('')) && isequal(unit(Ounits2), unit(''))
          Ounits1 = bs(jj).yunits;
          Ounits2 = bs(jj+1).yunits;
        end
        
        pfilts1.setIunits(Iunits1);
        pfilts1.setOunits(Ounits1);
        pfilts2.setIunits(Iunits2);
        pfilts2.setOunits(Ounits1);
        pfilts3.setIunits(Iunits1);
        pfilts3.setOunits(Ounits2);
        pfilts4.setIunits(Iunits2);
        pfilts4.setOunits(Ounits2);
        
        bs(jj)   = filter(cs(jj), pfilts1) + filter(cs(jj+1), pfilts2);
        bs(jj+1) = filter(cs(jj), pfilts3) + filter(cs(jj+1), pfilts4);
        
        % -----------------------------------
        % 4) Output data
        % name for this objects
        bs(jj).name = sprintf('noisegen2D(%s)_c1', [ao_invars{jj} ao_invars{jj+1}]);
        bs(jj+1).name = sprintf('noisegen2D(%s)_c2', [ao_invars{jj} ao_invars{jj+1}]);
        % Collect the filters into procinfo
        bs(jj).procinfo = plist('Filt11', pfilts1,'Filt12', pfilts2);
        bs(jj+1).procinfo = plist('Filt21', pfilts3,'Filt22', pfilts4);
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
      
    case 'filter'
      
      pfilts1.setIunits(Iunits);
      pfilts1.setOunits(Ounits);
      pfilts2.setIunits(Iunits);
      pfilts2.setOunits(Ounits);
      pfilts3.setIunits(Iunits);
      pfilts3.setOunits(Ounits);
      pfilts4.setIunits(Iunits);
      pfilts4.setOunits(Ounits);
      
      fil11 = filterbank(plist('filters',pfilts1,'type','parallel'));
      fil11.setName('filter 11');
      fil12 = filterbank(plist('filters',pfilts2,'type','parallel'));
      fil12.setName('filter 12');
      fil21 = filterbank(plist('filters',pfilts3,'type','parallel'));
      fil21.setName('filter 21');
      fil22 = filterbank(plist('filters',pfilts4,'type','parallel'));
      fil22.setName('filter 22');
      
      fil = matrix(plist('objs',[fil11,fil21,fil12,fil22],'shape',[2 2]));
      fil.setName(sprintf('noisegen2D(%s)',ao_invars{:}));
      fil.addHistory(getInfo('None'), pl, ao_invars, inhists);
      
      % Single output
      varargout{1} = fil;
      
  end
  
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setArgsmin(2);
  ii.setOutmin(1);
  ii.setModifier(false);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'Default', ...
    'Filter'   ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
  switch lower(set)
    case 'default'
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
      
      % Yunits
      p = param({'yunits',['Unit on Y axis. <br>' ...
        'If left empty, it will take the y-units from the input objects']}, {'',''});
      pl.append(p);
      
    case 'filter'
      
      % Fs
      p = param({'fs','The sampling frequency to design for.'}, paramValue.DOUBLE_VALUE(1));
      pl.append(p);
      
      % Iunits
      p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Ounits
      p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
  end
  
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
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
end



