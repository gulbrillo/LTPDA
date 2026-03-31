% NOISEGEN1D generates colored noise from white noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: noisegen1D can work in two different modes:
%
% ------------------------------------------------------------------------
% 1) Generates colored noise from white noise with a given spectrum. The
% function constructs a coloring filter through a fitting procedure to the
% model provided. If no model is provided an error is prompted. The colored
% noise provided has one-sided psd corresponding to the input model.
%
% This mode correspond to the 'Default' set for the method (see the list of
% parameters).
%
% ALGORITHM:
%            1) Fit a set of partial fraction z-domain filters using
%               utils.math.psd2tf
%            2) Convert to array of MIIR filters
%            3) Filter time-series in parallel
%
% CALL:         b = noisegen1D(a, pl)
%
% INPUT:
%               - a is a white noise time-series analysis object or a
%               vector of analysis objects
%               - pl is a plist with the input parameters
%
% OUTPUT:
%
%               - b Colored time-series AOs. The coloring filters used
%               are stored in the objects procinfo field under the
%               parameter 'Filt'.
%
% ------------------------------------------------------------------------
%
% 2) Generates noise coloring filters for given input psd models.
%
% This mode correspond to the 'Filter' set for the method (see the list of
% parameters).
%
% ALGORITHM:
%            1) Fit a set of partial fraction z-domain filters
%            2) Convert to array of MIIR filters
%
% CALL:         fil = noisegen1D(psd, pl)
%
% INPUT:
%               - psd is a fsdata analysis object representing the desired
%               model for the power spectral density of the colored noise
%               - pl is a plist with the input parameters
%
% OUTPUT:
%
%               - fil is a filterbank parallel object which elements are
%               miir filters. Filters are initialized to avoid startup
%               transients.
%
% ------------------------------------------------------------------------
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'noisegen1D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = noisegen1D(varargin)
  
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
  elseif isa(as(1).data,'fsdata') % get model from input
    setpar = 'Filter';
  else % get model from plist, output tsdata, back compatibility mode
    setpar = 'Default';
  end
  
  pl = applyDefaults(getDefaultPlist(setpar), pl);
  pl.getSetRandState();
  
  switch lower(setpar)
    case 'default'
      % Extract necessary parameters
      model = find_core(pl, 'model');
    case 'filter'
      fs     = find_core(pl,'fs');
      Iunits = find_core(pl, 'Iunits');
      Ounits = find_core(pl, 'Ounits');
      
      % init filter objects
      fil = filterbank.initObjectWithSize(size(bs,1),size(bs,2));
  end
  
  % start building input structure for psd2tf
  params.idtp = 1;
  params.Nmaxiter = find_core(pl, 'MaxIter');
  params.minorder = find_core(pl, 'MinOrder');
  params.maxorder = find_core(pl, 'MaxOrder');
  params.spolesopt = find_core(pl, 'PoleType');
  params.weightparam = find_core(pl, 'Weights');
  params.spy = find_core(pl, 'Disp');
  
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
  
  params.usesym = 0;
  params.dterm = 0; % it is better to fit without dterm
  
  % Loop over input AOs
  for jj=1:numel(bs)
    
    % It is necessary to store for each AO the random state.
    plh = pl.getSetRandState();
    
    switch lower(setpar)
      case 'default'
        if ~isa(bs(jj).data, 'tsdata')
          warning('!!! %s expects ao/tsdata objects. Skipping AO %s', mfilename, ao_invars{jj});
        else
          %-------------- Colored noise from white noise
          
          % 1) If we have no model gives an error
          if(isempty(model))
            error('!!! Input a model for the desired PSD')
          end
          
          % 2) Noise Generation
          
          params.fs = bs(jj).fs;
          
          % call psd2tf
          [res, poles, dterm, mresp, rdl] = ...
            utils.math.psd2tf(model.y,[],[],[],model.x,params);
          
          % get init state
          Zi = utils.math.getinitstate(res,poles,1,'mtd','svd');
          
          % 3) Convert to MIIR filters
          % add yunits, taking them from plist or, if empty, from input object
          Iunits = as(jj).yunits;
          Ounits = find_core(plh, 'yunits');
          if isequal(unit(Ounits), unit(''))
            Ounits = as(jj).yunits;
          end
          pfilts = [];
          for kk=1:numel(res)
            ft = miir(res(kk), [ 1 -poles(kk)], bs(jj).fs);
            ft.setIunits(Iunits);
            ft.setOunits(Ounits);
            ft.setHistout(Zi(kk));
            % build parallel bank of filters
            pfilts = [pfilts ft];
          end
          
          % 4) Filter data
          bs(jj).filter(pfilts);
          
          % 5) Output data
          % add history
          bs(jj).addHistory(getInfo('None'), plh, ao_invars(jj), inhists(jj));
          % name for this object
          bs(jj).setName(sprintf('noisegen1D(%s)', ao_invars{jj}));
          % Collect the filters into procinfo
          bs(jj).procinfo = plist('filter', pfilts);
          
        end
      case 'filter'
        
        params.fs = fs;
        
        % call psd2tf
        [res, poles, dterm, mresp, rdl] = ...
          utils.math.psd2tf(bs(jj).y,[],[],[],bs(jj).x,params);
        
        % get init state
        Zi = utils.math.getinitstate(res,poles,1,'mtd','svd');
        
        % build miir
        pfilts = [];
        for kk=1:numel(res)
          ft = miir(res(kk), [ 1 -poles(kk)], fs);
          ft.setIunits(Iunits);
          ft.setOunits(Ounits);
          ft.setHistout(Zi(kk));
          % build parallel bank of filters
          pfilts = [pfilts ft];
        end
        
        % build output filterbanks
        fil(jj) = filterbank(plist('filters',pfilts,'type','parallel'));
        fil(jj).setName(sprintf('noisegen1D(%s)',ao_invars{jj}));
        fil(jj).addHistory(getInfo('None'), plh, ao_invars(jj), inhists(jj));
    end
  end
  
  % switch output
  switch lower(setpar)
    
    case 'default'
      
      % set outputs
      varargout = utils.helper.setoutputs(nargout, bs);
      
    case 'filter'
      
      % set outputs
      varargout = utils.helper.setoutputs(nargout, fil);
      
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
      % Yunits
      p = param({'yunits',['Unit on Y axis. <br>' ...
        'If left empty, it will take the y-units from the input object']},  paramValue.STRING_VALUE(''));
      pl.append(p);
      
      % Model
      p = param({'model', 'A frequency-series AO describing the model psd'}, paramValue.EMPTY_DOUBLE);
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
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
  
end


