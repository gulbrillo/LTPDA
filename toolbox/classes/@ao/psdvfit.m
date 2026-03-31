% psdvfit performs a fitting loop to identify model for a psd.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: psdvfit fit a partial fraction model to frequency
%     response data using  the function utils.math.vcfit.
%
%     The function performs a fitting loop to automatically identify model. 
%     Output is a model of the spectrum. Fit function is a ratio of
%     polynomials in the form of partial fraction expension.
%
%              r1              rN
%     f(s) = ------- + ... + -------
%            s - p1          s - pN
%
%     After a first fitting step, the fit can be regularized in order to
%     obtain a statistically consistent model for the expected value of the
%     spectrum.
%     Automatic regularization is obtained checking the difference between
%     the maximum of the expected gamma function and the histogram of the
%     normalized spectrum (psd divided by the model frequency by
%     frequency).
%
%     The function can also perform a single loop without taking care of
%     the stop conditions. This happens when 'AutoSearch' parameter is
%     setted to 'off'.
%
%     The method accepts only 1 ao at the input.
%
% CALL:         [fit,confBands,mfhMod,mfhConfBand] = psdvfit(a, pl)
%
% INPUTS:      a  - input AOs to fit.
%              pl - parameter list
%
% OUTPUTS:
%               fit - ao containing the fitted model.
%               confBands - Lower and upper confidence band.
%               mfhMod - a mfh model that can be used to evaluate the model
%               on a different frequency grid.
%               mfhConfBand - mfh models for the confidence bands.
%
%
% Note: Gamma function assumption for the spectrum is strictly true only with
%     Gaussian distributed noise (time series). In case the noise in time
%     domain is non-Gaussian the Gamma is an approximation based on the
%     norilizing properties of the fft. Even if noise series is
%     non-Gaussian, real and imaginary part of the fft tend to a Gaussian
%     because are the result of the sum of many terms.
%
%
% EXAMPLES:
%
%   % Fitting parameter list
%   pl_fit = plist(...
%   'maxiter',50,...
%   'minorder',9,...
%   'maxorder',20,...
%   'FITTOL',1.7,...
%   'Plot','on');
%
%   % Do fit
%   [fit,confBands,mfhMod,mfhConfBand] = psdvfit(a, pl_fit);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'psdvfit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = psdvfit(varargin)
  
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
    error('### psdvfit cannot be used as a modifier. Please give an output variable.');
  end
  
  if numel(as)>1
    error('### psdvfit can fit only one PSD per time.');
  end
  
  % checking that AOs are fsdata and skipping non fsdata objects
  if ~isa(as.data, 'fsdata')
    error('### Input should be a spectrum so we expect fsdata at the input.');
  end
  
  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);
  inhists = [as.hist];
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%%%% Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  maxiter = find_core(pl, 'maxiter'); % set the maximum number of iterations
  minorder = find_core(pl, 'minorder'); % set the minimum function order
  maxoredr = find_core(pl, 'maxorder');% set the maximum function order
  maxspread = find_core(pl, 'fittol');% set the fit tolerance
  downsamplespectrum = find_core(pl, 'downsamplespectrum');% decide to skip some bins of the spectrum in order to have independent samples
  downsamplebins = find_core(pl, 'downsamplebins');% number of bins to skip
  regularize = find_core(pl, 'regularize');% decide to regularize the fit
  regularizecoeff = find_core(pl, 'regularizecoeff');% coefficient for regularization
  
  
  % decide to plot or not
  plt = find_core(pl, 'plot');
  switch lower(plt)
    case 'on'
      showplot = 1;
    case 'off'
      showplot = 0;
  end
 
  
  % decide to disp or not the fitting progress in matlab command window
  prg = find_core(pl, 'CheckProgress');
  switch lower(prg)
    case 'on'
      spy = 1;
    case 'off'
      spy = 0;
  end
  
  % decide to perform or not a full automatic model search
  autos = find_core(pl, 'AutoSearch');
  switch lower(autos)
    case 'on'
      fullauto = 1;
    case 'off'
      fullauto = 0;
  end
  
  % get navs from data
  navs = bs.data.navs;
  
  %%%%% End Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%% Downsample spectrum if required %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if downsamplespectrum
    [f,y] = utils.math.downsampleSpectrum(bs.x,bs.y,downsamplebins);
  else
    f = bs.x;
    y = bs.y;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  %%%%% Fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Fit parameters
  params = struct(...
    'Nmaxiter',maxiter,...
    'minorder',minorder,...
    'maxorder',maxoredr,...
    'plot',showplot,...
    'maxspread',maxspread,...
    'spy',spy,...
    'fullauto',fullauto);

  [res,poles,dterm,psdmod] = utils.math.psdvectorfit(y,f,params);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%% Regularization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if regularize
    
    yr = utils.math.regularizePSDForFit(y,psdmod,regularizecoeff,navs);
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%% Fittig regularized data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if regularize
    
    params = struct(...
    'Nmaxiter',maxiter,...
    'minorder',numel(poles),...
    'maxorder',maxoredr,...
    'plot',showplot,...
    'maxspread',maxspread,...
    'spy',spy,...
    'fullauto',fullauto);

  [res,poles,dterm,psdmod] = utils.math.psdvectorfit(yr,f,params);
    
  end
  
  
  
  %%%%% Build model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
  psdunits = as.yunits;
  
  mdlpl = plist(...
    'name',sprintf('fit(%s)', ao_invars{:}),...
    'description','fit to the expected value of the PSD',...
    'func','abs(resp(parfrac(plist(''res'',res,''poles'',poles,''dir'',dterm,''ounits'',psdunits)),plist(''f'',f)))',...
    'constants',{'res','poles','dterm','psdunits'},...
    'constant objects',{res,poles,dterm,psdunits},...
    'inputs','f');
  
  mdl = mfh(mdlpl);
  
  % set the procinfo with the parfrac object
  % NOTE: Only the absolute value of the model response reproduces the
  % spectrum. In general the model response is complex
  fit_model = parfrac(plist('res',res,'poles',poles,'dir',dterm,'ounits',psdunits));
  fit_model.setName('fit_model');
  fit_model.setDescription(['Fit to the expected value of the PSD. '...
    'NOTE: Only the absolute value of the model response reproduces the spectrum. '...
    'In general the model response is complex.']);
  
  plproc = plist('fit_model',fit_model);
  mdl.setProcinfo(plproc);

  %%%%% Build output object %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  bs.setDx([]);
  bs.setDy([]);
  
  bs.setY(psdmod);
  bs.setX(f);

  bs.setName(sprintf('fit(%s)', ao_invars{:}));
  
  bs.addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);
  
  %%%%% get 95% confidence bands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Get confidence bands for the model of the spectrum extracted from the
  % gamma distribution
  conf = 0.95;
  alpha = [(1-conf)/2 1-(1-conf)/2];
  A = navs;
  B = 1/navs;
  Xgamma = B.*gammaincinv(alpha,A);
  
  cbands(1) = copy(bs,1);
  cbands(1).setY(bs.y.*Xgamma(1));
  cbands(1).setName('95% Lower Confidence Band');
 
  cbands(2) = copy(bs,1);
  cbands(2).setY(bs.y.*Xgamma(2));
  cbands(2).setName('95% Upper Confidence Band');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%% mfh models for confidence bands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  mdlpl1 = plist(...
    'name','95% Lower Confidence Band',...
    'description','95% confidence band for the fit to the expected value of the PSD',...
    'func','clw.*abs(resp(parfrac(plist(''res'',res,''poles'',poles,''dir'',dterm,''ounits'',psdunits)),plist(''f'',f)))',...
    'constants',{'clw','res','poles','dterm','psdunits'},...
    'constant objects',{Xgamma(1),res,poles,dterm,psdunits},...
    'inputs','f');
  
  cmdl(1) = mfh(mdlpl1);
  
  mdlpl2 = plist(...
    'name','95% Upper Confidence Band',...
    'description','95% confidence band for the fit to the expected value of the PSD',...
    'func','cup.*abs(resp(parfrac(plist(''res'',res,''poles'',poles,''dir'',dterm,''ounits'',psdunits)),plist(''f'',f)))',...
    'constants',{'cup','res','poles','dterm','psdunits'},...
    'constant objects',{Xgamma(2),res,poles,dterm,psdunits},...
    'inputs','f');
  
  cmdl(2) = mfh(mdlpl2);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ----- Set outputs -----
  if nargout == 1
    varargout{1} = bs;
  elseif nargout == 2;
    varargout{1} = bs;
    varargout{2} = cbands;
  elseif nargout == 3;
    varargout{1} = bs;
    varargout{2} = cbands;
    varargout{3} = mdl;
  elseif nargout == 4;
    varargout{1} = bs;
    varargout{2} = cbands;
    varargout{3} = mdl;
    varargout{4} = cmdl;
  else
    % multiple output is not supported
    error('### Maximum output is 4 ###')
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
  
  % AutoSearch
  p = param({'AutoSearch', ['''on'': Parform a full automatic search for the<br>'...
    'transfer function order. The fitting<br>'...
    'procedure will stop when stop conditions<br>'...
    'defined are satisfied.<br>'...
    '''off'': Perform a fitting loop as long as the<br>'...
    'number of iteration reach ''maxiter''. The order<br>'...
    'of the fitting function will be that<br>'...
    'specified in ''minorder''.']}, ...
    {1, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);
 
  % MaxIter
  p = param({'MaxIter', 'Maximum number of iterations in fit routine.'}, paramValue.DOUBLE_VALUE(50));
  pl.append(p);
  
  % MinOrder
  p = param({'MinOrder', 'Minimum order to fit with.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % MaxOrder
  p = param({'MaxOrder', 'Maximum order to fit with.'}, paramValue.DOUBLE_VALUE(20));
  pl.append(p);
  
  % FITTOL
  p = param({'FITTOL', 'Fit tolerance. Check the maximu spread on the whitened spectrum.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, {2, {'on', 'off'}, paramValue.SINGLE});
  p.val.setValIndex(2);
  pl.append(p);
   
  % CheckProgress
  p = param({'CheckProgress', 'Display the status of the fit iteration.'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);
  
  % decide to downsample the spectrum in order to have independent bins
  p = param({'downsamplespectrum', 'Decide to downsample the spectrum in order to have independent bins.'}, ...
    paramValue.FALSE_TRUE);
  pl.append(p);
  
  % decide to downsample the spectrum in order to have independent bins
  p = param({'downsamplebins', 'Number of bins to skip in order to get independence.'}, ...
    paramValue.DOUBLE_VALUE(3));
  pl.append(p);
  
  % regularize data in order to have a statistically consistent model
  p = param({'regularize', 'Regularize data in order to have a statistically consistent model.'}, ...
    paramValue.TRUE_FALSE);
  pl.append(p);
  
  % regularize data in order to have a statistically consistent model
  p = param({'regularizecoeff', 'Regularization coefficient. Leave it empty if you want to do it automatically.'}, ...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
% END



