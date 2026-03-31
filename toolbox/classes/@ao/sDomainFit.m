% sDomainFit performs a fitting loop to identify model order and
% parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: sDomainFit fit a partial fraction model to frequency
%     response data using  the function utils.math.vcfit.
%
%     The function performs a fitting loop to automatically identify model
%     order and parameters in s-domain. Output is a s-domain model expanded
%     in partial fractions:
%
%              r1              rN
%     f(s) = ------- + ... + ------- + d
%            s - p1          s - pN
%
%     The function attempt to perform first the identification of a model
%     with d = 0, then if the operation do not succeed, it try the
%     identification with d different from zero.
%     %     Identification loop stop when the stop condition is reached.
%     Stop criterion is based on three different approachs:
%
%     1) Mean Squared Error and variation
%     Check if the normalized mean squared error is lower than the value specified in
%     FITTOL and if the relative variation of the mean squared error is lower
%     than the value specified in MSEVARTOL.
%     E.g. FITTOL = 1e-3, MSEVARTOL = 1e-2 search for a fit with
%     normalized magnitude error lower than 1e-3 and and MSE relative
%     variation lower than 1e-2.
%
%     1) Log residuals difference and root mean squared error
%     Log Residuals difference
%     Check if the minimum of the logarithmic difference between data and
%     residuals is larger than a specified value. ie. if the conditioning
%     value is 2, the function ensures that the difference between data and
%     residuals is at lest 2 order of magnitude lower than data itsleves.
%     Root Mean Squared Error
%     Check that the variation of the root mean squared error is lower than
%     10^(-1*value).
%
%     2) Residuals spectral flatness and root mean squared error
%     Residuals Spectral Flatness
%     In case of a fit on noisy data, the residuals from a good fit are
%     expected to be as much as possible similar to a white noise. This
%     property can be used to test the accuracy of a fit procedure. In
%     particular it can be tested that the spectral flatness coefficient of
%     the residuals is larger than a certain qiantity sf such that 0<sf<1.
%     Root Mean Squared Error
%     Check that the variation of the root mean squared error is lower than
%     10^(-1*value).
%
%     Both in the first and second approach the fitting loop stops when the
%     two stopping conditions are satisfied.
%     The output are AOs containing the frequency response of the fitted
%     model, while the Model parameters are output as a parfrac model
%     in the output AOs procinfo filed.
%
%     The function can also perform a single loop without taking care of
%     the stop conditions. This happens when 'AutoSearch' parameter is
%     setted to 'off'.
%
%     If you provide more than one AO as input, they will be fitted
%     together with a common set of poles.
%
% CALL:         mod = sDomainFit(a, pl)
%
% INPUTS:      a  - input AOs to fit to. If you provide more than one AO as
%                   input, they will be fitted together with a common set
%                   of poles. Only frequency domain (fsdata) data can be
%                   fitted. Each non fsdata object will be ignored. Input
%                   objects must have the same number of elements.
%              pl - parameter list (see below)
%
% OUTPUTS:
%               mod - matrix of one parfrac object for each input AO.
%                     Usseful fit information are stored in the procinfoi
%                     field:
%                     FIT_RESP  - model frequency response.
%                     FIT_RESIDUALS - analysis object containing the fit
%                     residuals.
%                     FIT_MSE - analysis object containing the mean squared
%                     error progression during the fitting loop.
%
%
% Note: all the input objects are assumed to caontain the same X
% (frequencies) values
%
%
% EXAMPLES:
%
% 1) Fit to a frequency-series using Mean Squared Error and variation stop
% criterion
%
%   % Create a frequency-series AO
%   pl_data = plist('fsfcn', '0.01./(0.0001+f)', 'f1', 1e-5, 'f2', 5, 'nf', 1000);
%   a = ao(pl_data);
%
%   % Fitting parameter list
%   pl_fit = plist('AutoSearch','on',...
%   'StartPoles',[],...
%   'StartPolesOpt','clog',...
%   'maxiter',5,...
%   'minorder',2,...
%   'maxorder',20,...
%   'weights',[],...
%   'CONDTYPE','MSE',...
%   'FITTOL',1e-3,...
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'direct term','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = sDomainFit(a, pl_fit);
%
% 2) Fit to a frequency-series using Log residuals difference and mean
% squared error variation stop criterion
%
%   % Create a frequency-series AO
%   pl_data = plist('fsfcn', '0.01./(0.0001+f)', 'f1', 1e-5, 'f2', 5, 'nf', 1000);
%   a = ao(pl_data);
%
%   % Fitting parameter list
%   pl_fit = plist('FS',[],...
%   'AutoSearch','on',...
%   'StartPoles',[],...
%   'StartPolesOpt','clog',...
%   'maxiter',5,...
%   'minorder',2,...
%   'maxorder',20,...
%   'weights',[],...
%   'weightparam','abs',...
%   'CONDTYPE','RLD',...
%   'FITTOL',1e-3,...
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = sDomainFit(a, pl_fit);
%
% 3) Fit to a frequency-series using Residuals spectral flatness and mean
% squared error variation stop criterion
%
%   % Create a frequency-series AO
%   pl_data = plist('fsfcn', '0.01./(0.0001+f)', 'f1', 1e-5, 'f2', 5, 'nf', 1000);
%   a = ao(pl_data);
%
%   % Fitting parameter list
%   pl_fit = plist('FS',[],...
%   'AutoSearch','on',...
%   'StartPoles',[],...
%   'StartPolesOpt','clog',...
%   'maxiter',5,...
%   'minorder',2,...
%   'maxorder',20,...
%   'weights',[],...
%   'weightparam','abs',...
%   'CONDTYPE','RSF',...
%   'FITTOL',0.5,...
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = sDomainFit(a, pl_fit);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sDomainFit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sDomainFit(varargin)
  
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
    error('### sDomainFit cannot be used as a modifier. Please give an output variable.');
  end
  
  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);
  inhists = [as.hist];
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%%%% Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  extpoles = find_core(pl, 'StartPoles'); % Check if external poles are providied
  spolesopt = 0;
  if isempty(extpoles) % if no external poles set them internally
    splopt = find_core(pl, 'StartPolesOpt');
    switch lower(splopt)
      case 'real'
        spolesopt = 1;
      case 'clog'
        spolesopt = 2;
      case 'clin'
        spolesopt = 3;
    end
  end
  
  maxiter = find_core(pl, 'maxiter'); % set the maximum number of iterations
  minorder = find_core(pl, 'minorder'); % set the minimum function order
  maxoredr = find_core(pl, 'maxorder');% set the maximum function order
  
  extweights = find_core(pl, 'weights'); % check if external weights are provided
  weightparam = 0;
  if isempty(extweights) % set internally the weights on the basis of the input options
    wtparam = find_core(pl, 'weightparam');
    switch lower(wtparam)
      case 'ones'
        weightparam = 1;
      case 'abs'
        weightparam = 2;
      case 'sqrt'
        weightparam = 3;
    end
  end
  
  % decide to plot or not
  plt = find_core(pl, 'plot');
  switch lower(plt)
    case 'on'
      showplot = 1;
    case 'off'
      showplot = 0;
  end
  
  % Make a decision between Fit conditioning type
  condtype = find_core(pl, 'CONDTYPE');
  condtype = upper(condtype);
  switch condtype
    case 'MSE'
      ctp = 'chivar'; % use normalized mean squared error value and relative variation
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
    case 'RLD'
      ctp = 'lrsmse'; % use residuals log difference and MSE relative variation
      lrscond = find_core(pl, 'FITTOL');
      % give a warning for strange values of lrscond
      if lrscond<0
        error('!!! Negative values for FITTOL are not allowed !!!')
      end
      if lrscond<1
        warning('You are searching for a frequency by frequency residuals log difference of %s', num2str(lrscond))
      end
    case 'RSF'
      ctp = 'rftmse'; % use residuals spectral flatness and MSE relative variation
      lrscond = find_core(pl, 'FITTOL');
      % give a warning for strange values of lrscond
      if lrscond<0 || lrscond>1
        error('!!! Values <0 or >1 for FITTOL are not allowed when CONDTYPE is RSF !!!')
      end
  end
  
  % Tolerance for the MSE relative variation
  msevar = find_core(pl, 'MSEVARTOL');
  % handling data
  msevar = -1*log10(msevar);
  % give a warning for strange values of msevar
  if msevar<0
    warning('You are searching for MSE relative variation lower than %s', num2str(10^(-1*msevar)))
  end
  
  % decide to stabilize or not the model
  stab = find_core(pl, 'ForceStability');
  switch lower(stab)
    case 'on'
      stabfit = 1;
    case 'off'
      stabfit = 0;
  end
  
  % decide to fit with or whitout direct term
  dtm = find_core(pl, 'direct term');
  switch lower(dtm)
    case 'on'
      dterm = 1;
    case 'off'
      dterm = 0;
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
  
  % extract delay
  delay = find_core(pl, 'delay');
  
  %%%%% End Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  %%%%% Fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Fit parameters
  params = struct('spolesopt',spolesopt,...
    'extpoles', extpoles,...
    'Nmaxiter',maxiter,...
    'minorder',minorder,...
    'maxorder',maxoredr,...
    'weightparam',weightparam,...
    'extweights', extweights,...
    'plot',showplot,...
    'ctp',ctp,...
    'lrscond',lrscond,...
    'msevar',msevar,...
    'stabfit',stabfit,...
    'dterm',dterm,...
    'spy',spy,...
    'fullauto',fullauto);
  
  %%% extracting elements from AOs
  
  % Finding the index of the first fsdata
  for gg = 1:numel(bs)
    if isa(bs(gg).data, 'fsdata')
      prm = gg;
      break
    end
  end
  
  y = zeros(length(bs(prm).data.getY),numel(bs)); % initialize input vector
  k = numel(bs(prm).data.getY); % setting a comparison constant
  idx = true(numel(bs),1); % initialize the control index
  for jj=1:numel(bs)
    % checking that AOs are fsdata and skipping non fsdata objects
    if ~isa(bs(jj).data, 'fsdata')
      % skipping data if non fsdata
      warning('!!! %s expects ao/fsdata objects. Skipping AO %s', mfilename, ao_invars{jj});
      idx(jj) = false; % set the corresponding value of the control index to false
    else
      % preparing data for fit
      yt = bs(jj).data.getY;
      ounits = bs(jj).yunits;
      if numel(yt)~=k
        error('Input AOs must have the same number of elements')
      end
      if size(yt,2)>1 % wish to work with columns
        y(:,jj) = yt.';
      else
        y(:,jj) = yt;
      end
    end
  end
  %%% extracting frequencies
  % Note: all the objects are assumed to caontain the same X (frequencies) values
  f = bs(prm).data.getX;
  
  % reshaping y to contain only Y from fsdata, subtract delay if given by
  % user
  if ~isempty(delay)
    y = y(:,idx)./exp(-2*pi*1i*f*delay);
  else
    y = y(:,idx);
  end
  
  % Fitting loop
  [res,poles,dterm,mresp,rdl,mse] = utils.math.autocfit(y,f,params);
  
  %%%%% Building output AOs with model responses, model parameters are %%%%
  
  for kk = 1:numel(bs)
    if idx(kk) % set the corresponding Y values of fitted data
      
      % if delay is input we return a pzmodel with the corresponding delay
      if isempty(delay)
        mdl(kk) = parfrac(plist('res', res(:,kk),'poles', poles, 'dir',...
          dterm(:,kk), 'ounits', ounits, 'name', sprintf('fit(%s)', ao_invars{kk})));
      else
        mdl_aux = parfrac(plist('res', res(:,kk),'poles', poles, 'dir',...
          dterm(:,kk), 'ounits', ounits, 'name', sprintf('fit(%s)', ao_invars{kk})));
        mdl(kk) = pzmodel(mdl_aux);
        mdl(kk).setDelay(delay);
      end
      
      % Output also response, residuals and mse progression in the procinfo
      
      rsp = mresp(:,kk);
      bs(kk).data.setY(rsp);
      
      % Set output AO name
      bs(kk).name = sprintf('fit(%s)', ao_invars{kk});
      
      res_ao = copy(bs(kk),1);
      trdl = rdl(:,kk);
      res_ao.data.setY(trdl);
      
      % Set output AO name
      res_ao.name = sprintf('fit_residuals(%s)', ao_invars{kk});
      
      d = cdata();
      tmse = mse(:,kk);
      d.setY(tmse);
      mse_ao = ao(d);
      
      % Set output AO name
      mse_ao.name = sprintf('fit_mse(%s)', ao_invars{kk});
      
      procpl = plist('fit_resp',bs(kk),...
        'fit_residuals',res_ao,...
        'fit_mse',mse_ao);
      
      mdl(kk).setProcinfo(procpl);
      
    else
      mdl(kk) = parfrac();
    end
    
  end
  
  % set output as matrix if multiple inputs
  if numel(mdl) ~= 1
    mmdl = matrix(mdl);
  else
    mmdl = mdl;
  end
  
  mmdl.setName(sprintf('fit(%s)', ao_invars{:}));
  
  mmdl.addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);
  
  % ----- Set outputs -----
  if nargout == 1
    varargout{1} = mmdl;
  else
    % multiple output is not supported
    error('### Multiple output is not supported ###')
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
  
  % StartPoles
  p = param({'StartPoles', ['A vector of starting poles. Providing a fixed<br>'...
    'set of starting poles fixes the function<br>'...
    'order. If it is left empty starting poles are<br>'...
    'internally assigned.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % StartPolesOpt
  p = param({'StartPolesOpt', ['Define the characteristics of internally<br>'...
    'assigned starting poles. Admitted values<br>'...
    'are:<ul>'...
    '<li>''real'' linear-spaced real poles</li>'...
    '<li>''clog'' log-spaced complex poles</li>'...
    '<li>''clin'' linear-spaced complex poles<li></ul>']}, ...
    {2, {'real', 'clog', 'clin'}, paramValue.SINGLE});
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
  
  % Weights
  p = param({'Weights', ['A vector with the desired weights. If a single<br>'...
    'Ao is input weights must be a Nx1 vector where<br>'...
    'N is the number of elements in the input Ao. If<br>'...
    'M Aos are passed as input, then weights must<br>'...
    'be a NxM matrix. If it is leaved empty weights<br>'...
    'are internally assigned basing on the input<br>'...
    'parameters']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Weightparam
  p = param({'weightparam', ['Specify the characteristics of the internally<br>'...
    'assigned weights. Admitted values are:<ul>'...
    '<li>''ones'' assigns weights equal to 1 to all data.<li>'...
    '<li>''abs'' weights data with <tt>1./abs(y)</tt></li>'...
    '<li>''sqrt'' weights data with <tt>1./sqrt(abs(y))</tt></li>']}, ...
    {2, {'ones', 'abs', 'sqrt'}, paramValue.SINGLE});
  pl.append(p);
  
  % CONDTYPE
  p = param({'CONDTYPE', ['Fit conditioning type. Admitted values are:<ul>'...
    '<li>''MSE'' Mean Squared Error and variation</li>'...
    '<li>''RLD'' Log residuals difference and mean squared error variation<li>'...
    '<li>''RSF'' Residuals spectral flatness and mean squared error variation<li></ul>']}, ...
    {1, {'MSE', 'RLD', 'RSF'}, paramValue.SINGLE});
  pl.append(p);
  
  % FITTOL
  p = param({'FITTOL', 'Fit tolerance.'}, paramValue.DOUBLE_VALUE(1e-3));
  pl.append(p);
  
  % MSEVARTOL
  p = param({'MSEVARTOL', ['Mean Squared Error Variation - Check if the<br>'...
    'realtive variation of the mean squared error is<br>'...
    'smaller than the value specified. This<br>'...
    'option is useful for finding the minimum of Chi-squared.']}, ...
    paramValue.DOUBLE_VALUE(1e-2));
  pl.append(p);
  
  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, {2, {'on', 'off'}, paramValue.SINGLE});
  p.val.setValIndex(2);
  pl.append(p);
  
  % ForceStability
  p = param({'ForceStability', 'Force poles to be stable'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);
  
  % direct term
  p = param({'direct term', 'Fit with direct term.'}, {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);
  
  % CheckProgress
  p = param({'CheckProgress', 'Display the status of the fit iteration.'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);
  
  % Delay
  p = param({'delay', 'Innput a delay that will be subtracted from the fit.<br>'...
    'The output is a pzmodel which includes the inputted delay.'},paramValue.EMPTY_DOUBLE);
  pl.append(p);
end
% END


% PARAMETERS:
%             'AutoSearch'  - 'on': Parform a full automatic search for the
%                             transfer function order. The fitting
%                             procedure will stop when stop conditions
%                             defined are satisfied. [Default]
%                             'off': Perform a fitting loop as long as the
%                             number of iteration reach 'maxiter'. The order
%                             of the fitting function will be that
%                             specified in 'minorder'.
%             'StartPoles'  - A vector of starting poles. Providing a fixed
%                             set of starting poles fixes the function
%                             order. If it is left empty starting poles are
%                             internally assigned. [Default []]
%             'StartPolesOpt' - Define the characteristics of internally
%                               assigned starting poles. Admitted values
%                               are:
%                               'real' linspaced real poles
%                               'clog' logspaced complex poles [Default]
%                               'clin' linspaced complex poles
%             'maxiter'   - Maximum number of allowed iteration. [Deafult
%                           50].
%             'minorder'  - Minimum model function order. [Default 2]
%             'maxorder'  - Maximum model function order. [Default 20]
%             'weights'   - A vector with the desired weights. If a single
%                           Ao is input weights must be a Nx1 vector where
%                           N is the number of elements in the input Ao. If
%                           M Aos are passed as input, then weights must
%                           be a NxM matrix. If it is leaved empty weights
%                           are internally assigned basing on the input
%                           parameters. [Default []]
%             'weightparam' - Specify the characteristics of the internally
%                             assigned weights. Admitted values are:
%                             'ones' assigns weights equal to 1 to all data.
%                             'abs' weights data with 1./abs(y) [Default]
%                             'sqrt' weights data with 1./sqrt(abs(y))
%             'CONDTYPE'  - Fit conditioning type. Admitted values are:
%                             - 'MSE' Mean Squared Error and variation
%                             [Default]
%                             - 'RLD' Log residuals difference and mean
%                             squared error variation
%                             - 'RSF' Residuals spectral flatness and mean
%                             squared error variation
%               'FITTOL'  - Fit tolerance [Default, 1e-3]
%           'MSEVARTOL'   - This allow to check if the relative variation
%                           of mean squared error is lower than the value
%                           sepcified. [Default 1e-2]
%             'Plot'        - Plot fit result: 'on' or 'off' [default]
%             'ForceStability'  - Force poles to be stable, values are
%                                 'on' or 'off'. [Default 'off']
%             'direct term' - Fit with direct term if 'on', without if
%                             'off'. [Default 'off']
%             'CheckProgress' - Disply the status of the fit iteration.
%                               Values are 'on and 'off'. [Default 'off']
%
%

