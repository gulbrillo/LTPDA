% BUILDWHITENER1D builds a whitening filter based on the input frequency-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:BUILDWHITENER1D builds a whitening filter based on the input frequency-series.
%              The filter is built by fitting to the model provided.
%              If no model is provided, a fit is made to a spectral-density estimate of the
%              input time-series (made using psd+bin_data or lpsd).
%              Note: The function assumes that the input model corresponds
%              to the one-sided psd of the data to be whitened.
%
% ALGORITHM:
%            1) If no model provided, make psd+bin_data or lpsd
%               of time-series and take it as a model
%               for the data power spectral density
%            2) Fit a set of partial fraction z-domain filters using
%               utils.math.psd2wf. The fit is automatically stopped when
%               the accuracy tolerance is reached.
%            3) Convert to array of MIIR filters
%            4) Assemble into a parallel filterbank object
%
%
% CALL:         b = buildWhitener1D(a, pl)
%               [b1,b2,...,bn] = buildWhitener1D(a1,a2,...,an, pl);
%
% INPUT:
%               - as is a time-series analysis object or a vector of
%               analysis objects
%               - pl is a plist with the input parameters
%
% OUTPUT:
%               - b "whitening" filters, stored into a filterbank.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'buildWhitener1D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = buildWhitener1D(varargin)
  
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
  
  if nargout == 0
    error('### buildWhitener cannot be used as a modifier. Please give an output variable.');
  end
  
  % combine plists
  if isempty(pl)
    model = 'psd';
  else
    model = find_core(pl, 'model');
    if isempty(model)
      model = 'psd';
      pl.pset('model', model);
    end
  end
  
  if ischar(model)
    pl = applyDefaults(getDefaultPlist(model), pl);
  else
    pl = applyDefaults(getDefaultPlist('Default'), pl);
  end
  pl.getSetRandState();
  
  % Collect input histories
  inhists = [as.hist];
  
  % Initialize output objects
  bs = filterbank.initObjectWithSize(1, numel(as));
  
  
  % Loop over input AOs
  for jj = 1:numel(as)
    % 1) searching for input model
    switch class(as(jj).data)
      case 'tsdata'
        % Build the model based on input time-series
        utils.helper.msg(msg.PROC1, 'user input tsdata object, estimating the model from it');
        model = estimateModel(as(jj), pl);
      case 'fsdata'
        % The input data are the model
        utils.helper.msg(msg.PROC1, 'user input fsdata object, taking it as the model');
        model = as(jj);
      otherwise
        warning('!!! %s expects ao/tsdata or ao/fsdata objects. Skipping AO %s', mfilename, ao_invars{jj});
        return;
    end
    
    %-------------- Whiten this AO
    
    % Extract necessary parameters
    
    % Tolerance for MSE Value
    lrscond = find_core(pl, 'FITTOL');
    % give an error for strange values of lrscond
    if lrscond < 0
      error('!!! Negative values for FITTOL are not allowed !!!')
    end
    % handling data
    lrscond = -1 * log10(lrscond);
    % give a warning for strange values of lrscond
    if lrscond<0
      warning('You are searching for a MSE lower than %s', num2str(10^(-1*lrscond)))
    end
    params.lrscond = lrscond;
    
    % Tolerance for the MSE relative variation
    msevar = find_core(pl, 'MSEVARTOL');
    % handling data
    msevar = -1 * log10(msevar);
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
    
    % Weights
    switch find_core(pl, 'Weights')
      case {'equal', 'flat', 1}
        params.weightparam = 1;
      case {'1/abs', '1./abs', 2}
        params.weightparam = 2;
      case {'1/abs^2', '1/abs2', '1./abs^2', '1./abs2', 3}
        params.weightparam = 3;
      otherwise
        warning('Unrecognized weights option %s', find_core(pl, 'Weights'))
    end
    
    % 2) Build filters
    
    % Build input structure for psd2wf
    params.idtp = 1;
    params.Nmaxiter = find_core(pl, 'MaxIter');
    params.minorder = find_core(pl, 'MinOrder');
    params.maxorder = find_core(pl, 'MaxOrder');
    params.spolesopt = find_core(pl, 'PoleType');
    params.spy = find_core(pl, 'Disp');
    
    
    if (find_core(pl, 'plot'))
      params.plot = 1;
    else
      params.plot = 0;
    end
    
    fs = find_core(pl, 'fs');
    if isempty(fs) || fs <= 0 || ~isfinite(fs)
      if isempty(model.fs) || model.fs <= 0 || ~isfinite(model.fs)
        error('### Invalid fs value %s. Please specify a meaningful fs, either via the model or in the plist', num2str(fs));
      else
        fs = model.fs;
      end
    end
    
    params.fs = fs;
    params.usesym = 0;
    params.dterm = 0; % it is better to fit without direct term
    params.fullauto = 1;
    
    % call psd2wf
    [res, poles, dterm, mresp, rdl] = ...
      utils.math.psd2wf(model.y,[],[],[],model.x,params);
    
    % 3) Convert to MIIR filters
    
    % filtering with a stable model
    pfilts = [];
    for kk = 1:numel(res)
      ft = miir(res(kk), [ 1 -poles(kk)], fs);
      pfilts = [pfilts ft];
    end
    
    % 4) Build the output filterbank object
    bs(jj) = filterbank(plist('filters', pfilts, 'type', 'parallel'));
    % set the input units to be the same as the model
    bs(jj).setIunits(simplify(sqrt(model.yunits * unit.Hz)));
    % set the output units to be empty
    bs(jj).setOunits(unit());
    
    % set the name for this object
    bs(jj).name = sprintf('buildWhitener1D(%s)', ao_invars{jj});
    % add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhists(jj));
  end
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
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
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'Default', ...
    'PSD',    ...
    'LPSD'   ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end


function pl = buildplist(set)
  pl = plist();
  
  % Model
  p = param({'model', ['A model estimation technique in the case of tsdata input:<br>'...
    '<li>PSD - using <tt>psd</tt> + <tt>bin_data</tt></li>'...
    '<li>LPSD - using <tt>lpsd</tt></li>']}, {1, {'PSD', 'LPSD'}, paramValue.SINGLE});
  pl.append(p);
  
  % Range
  p = param({'range', ['The frequency range to evaluate the fitting.<br>' ...
    'An empty value or [-inf inf] will include the whole range.<br>' ...
    'The remaining part of the model will be completed according<br>' ...
    'to the option chosen in the ''complete'' parameter.<br>' ...
    ]}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Complete
  p = param({'complete_hf', ['Choose how to complete the frequency range up to fs/2.<ol>' ...
    '<li>Assumes flat response</li>' ...
    '<li>Assumes 4 poles low-pass type response</li>' ...
    ]}, {1,{'flat', 'lowpass'}, paramValue.SINGLE});
  pl.append(p);
  
  % fs
  p = param({'fs', ['The sampling frequency to design the output filter on.<br>' ...
    'If it is not a positive number, it will be taken from the model' ...
    ]}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % MaxIter
  p = param({'MaxIter', 'Maximum number of iterations in fit routine.'}, paramValue.DOUBLE_VALUE(30));
  pl.append(p);
  
  % PoleType
  p = param({'PoleType', ['Choose the pole type for fitting:<ol>'...
    '<li>use real starting poles</li>'...
    '<li>generates complex conjugate poles of the<br>'...
    'type <tt>a.*exp(theta*pi*j)</tt>'...
    'with <tt>theta = linspace(0,pi,N/2+1)</tt></li>'...
    '<li>generates complex conjugate poles of the type<br>'...
    '<tt>a.*exp(theta*pi*j)</tt><br>'...
    'with <tt>theta = linspace(0,pi,N/2+2)</tt></li></ol>']}, {1, {1, 2, 3}, paramValue.SINGLE});
  pl.append(p);
  
  % MinOrder
  p = param({'MinOrder', 'Minimum order to fit with.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % MaxOrder
  p = param({'MaxOrder', 'Maximum order to fit with.'}, paramValue.DOUBLE_VALUE(25));
  pl.append(p);
  
  % Weights
  p = param({'Weights', ['Choose weighting method:<ol>'...
    '<li>equal weights for each point</li>'...
    '<li>weight with <tt>1/abs(model)</tt></li>'...
    '<li>weight with <tt>1/abs(model).^2</tt></li></ol>']}, ...
    {2, {'equal', '1/abs', '1/abs^2'}, paramValue.SINGLE});
  pl.append(p);
  
  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Disp
  p = param({'Disp', 'Display the progress of the fitting iteration.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % MSEVARTOL
  p = param({'MSEVARTOL', ['Mean Squared Error Variation - Check if the<br>'...
    'relative variation of the mean squared error is<br>'...
    'smaller than the value specified. This<br>'...
    'option is useful for finding the minimum of Chi-squared.']}, ...
    paramValue.DOUBLE_VALUE(1e-1));
  pl.append(p);
  
  % FITTOL
  p = param({'FITTOL', ['Mean Squared Error Value - Check if the mean<br>'...
    'squared error value is lower than the value<br>'...
    'specified.']}, paramValue.DOUBLE_VALUE(1e-2));
  pl.append(p);
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
  % Append sets of parameters according to the chosen spectral estimator
  if ~utils.helper.ismember(lower(SETS), lower(set))
    error('### Unknown set [%s]', set);
  end
  
  switch lower(set)
    case 'default'
      pl.remove('model');
    case 'psd'
      pl = combine(pl, ao.getInfo('psd').plists);
      pl.pset(...
        'model', 'PSD', ...
        'Navs', 16, ...
        'order', 1, ...
        'olap', 50 ...
        );
      pl = combine(pl, ao.getInfo('bin_data').plists);
      pl.pset(...
        'method', 'MEAN', ...
        'resolution', 50 ...
        );
    case 'lpsd'
      pl = combine(pl, ao.getInfo('lpsd').plists);
      pl.pset(...
        'model', 'LPSD' ...
        );
    otherwise
  end
end


%--------------------------------------------------------------------------
% Estimate a model from the data or from user input
%--------------------------------------------------------------------------
function model = estimateModel(b, pl)
  
  import utils.const.*
  
  
  % Estimate a model for the PSD
  model_all = find_core(pl, 'model');
  if ischar(model_all)
    switch lower(model_all)
      case 'psd'
        % Select only the parameters associated to ao/psd
        pls = ao.getInfo('psd').plists;
        % Call ao/psd
        sp = psd(b, pl.subset(pls.getKeys()));
        % Select only the parameters associated to ao/bin_data
        pls = ao.getInfo('bin_data').plists;
        % Call ao/bin_data
        model_all = bin_data(sp, pl.subset(pls.getKeys()));
      case 'lpsd'
        % Select only the parameters associated to ao/lpsd
        pls = ao.getInfo('lpsd').plists;
        model_all = lpsd(b, pl.subset(pls.getKeys()));
      otherwise
        error('### Unknown model [%s]', model_all);
    end
  end
  
  % Select only a limited frequency range
  frange = find_core(pl, 'range');
  if isempty(frange)
    frange = [-inf inf];
  end
  model = model_all.split(plist('frequencies', frange));
  f1 = frange(1);
  f2 = frange(2);
  
  if isfinite(f2)
    % Select a technique to complete the high frequency range
    complete_up_opt = find_core(pl, 'complete_hf');
    switch complete_up_opt
      case {'flat', 'allpass', 'all pass', 'all-pass'}
        utils.helper.msg(msg.PROC1, 'Completing the frequency range from %s to %s with flat model', ...
          num2str(f2), num2str(b.fs/2));
        % Build a flat model response
        r = ones(size(model_all.x));
      case {'lowpass', 'low pass', 'low-pass'}
        utils.helper.msg(msg.PROC1, 'Completing the frequency range from %s to %s with 4 poles low-pass model', ...
          num2str(f2), num2str(b.fs/2));
        % Build a 4 poles low pass resp
        r = abs(resp(pzmodel(plist('gain', 1, 'poles', {10*f2,11*f2,12*f2,13*f2})), plist('f', model_all.x)));
        r = r.y;
      otherwise
        error('### Unknown option [%s] for high frequency completion', complete_up_opt);
    end
    model_hf =  r * model.y(end);
    model = join(model, ...
      ao(plist('type', 'fsdata', 'xvals', model_all.x, 'yvals', model_hf, 'fs', model_all.fs, 'yunits', model_all.yunits)));
  end
  
end


