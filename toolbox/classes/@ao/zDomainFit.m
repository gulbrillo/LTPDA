% zDomainFit performs a fitting loop to identify model order and
% parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: zDomainFit fit a partial fraction model to frequency
%     response data using the function utils.math.vdfit.
%
%     The function performs a fitting loop to automatically identify model
%     order and parameters in z-domain. Output is a z-domain model expanded
%     in partial fractions:
%
%             z*r1            z*rN
%     f(s) = ------- + ... + -------
%            z - p1          z - pN
%
%     The identification loop stop when the stop condition is reached.
% 
%     Output poles and residues are those with minimum Mean Square Error.
% 
%     The stop criterion is based on three different approaches, that can be
%     chosen by setting the value of the CONDTYPE parameter:
%
%     1) Mean Squared Error and variation 
%     (CONDTYPE = 'MSE')
%     Check if the normalized mean squared error is lower than the value specified in
%     the parameter FITTOL and if the relative variation of the mean squared error 
%     is lower than the value specified in the parameter MSEVARTOL.
%     E.g. FITTOL = 1e-3, MSEVARTOL = 1e-2 will search for a fit with
%     normalized magnitude error lower than 1e-3 and MSE relative
%     variation lower than 1e-2.
%
%     2) Residuals Log difference and mean squared error variation
%     (CONDTYPE = 'RLD')
%     Log Residuals difference
%     Check if the minimum of the logarithmic difference between data and
%     residuals is larger than a specified value. 
%     E.g. if the tolerance value is set to 2 (FITTOL = 2), the function 
%     ensures that the difference between data and residuals is at lest 2 
%     orders of magnitude lower than data itselves.
%     Mean Squared Error Variation
%     Check if the relative variation of the mean squared error is lower than
%     MSEVARTOL.
%
%     3) Residuals spectral flatness and mean squared error variation
%     (CONDTYPE = 'RSF')
%     Residuals Spectral Flatness
%     In case of a fit on noisy data, the residuals from a good fit are
%     expected to be as much as possible similar to a white noise. This
%     property can be used to test the accuracy of a fit procedure. In
%     particular it can be tested that the spectral flatness coefficient of
%     the residuals is larger than a certain quantity sf such that 0<sf<1.
%     E.g. if the tolerance value is set to 0.2 (FITTOL = 0.2), the function 
%     ensures that the spectral flatness coefficient of the residuals is 
%     larger than 0.2.
%     Root Mean Squared Error
%     Check if the relative variation of the mean squared error is lower than
%     MSEVARTOL.
%
%     Both in the first, second and third approaches the fitting loop ends 
%     when the two stopping conditions are satisfied.
%
%     The function can also perform a single loop without taking care of
%     the stop conditions. This happens when the 'AUTOSEARCH' parameter is
%     set to 'off'.
%
%     If you provide more than one AO as input, they will be fitted
%     together with a common set of poles.
%
% CALL:         mod = zDomainFit(a, pl)
%
% INPUTS:      a  - input AOs to fit to. If you provide more than one AO as
%                   input, they will be fitted together with a common set
%                   of poles. Only frequency domain (fsdata) data can be
%                   fitted. Each non-fsdata object will be ignored. Input
%                   objects must have the same number of elements.
%              pl - parameter list (see below)
%
% OUTPUTS:
%               mod - matrix object containing filterbanks of
%                     parallel miir filters for each input AO.
%                     Useful fit information are stored in the objects
%                     procinfo:
%                     FIT_RESP  - model frequency response.
%                     FIT_RESIDUALS - analysis object containing the fit
%                     residuals.
%                     FIT_MSE - analysis object containing the mean squared
%                     error progression during the fitting loop.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'zDomainFit')">Parameters Description</a>
%
% Note: all the input objects are assumed to caontain the same X
% (frequencies) values
%
%
% EXAMPLES:
%
% 1) Fit to a frequency-series using the 'MSE' conditioning criterion for
% fit accuracy
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
%   'CONDTYPE','MSE',...
%   'FITTOL',1e-3,... % check if MSE is lower than 1e-3
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = zDomainFit(a, pl_fit);
%
% 2) Fit to a frequency-series using the 'RLD' conditioning criterion for
% fit accuracy
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
%   'FITTOL',2,... % check if log10(abs(data))-log10(abs(fit_residuals)) > 2
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = zDomainFit(a, pl_fit);
%
% 3) Fit to a frequency-series using the 'RSF' conditioning criterion for
% fit accuracy
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
%   'FITTOL',0.7,... % check if residuals spectral flatness is larger than 0.7
%   'MSEVARTOL',1e-2,...
%   'Plot','off',...
%   'ForceStability','off',...
%   'CheckProgress','off');
%
%   % Do fit
%   b = zDomainFit(a, pl_fit);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = zDomainFit(varargin)

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

  %%% Decide on a deep copy or a modify
  bs = copy(as, nargout);
  inhists = [as.hist];

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  if nargout == 0
    error('### zDomainFit cannot be used as a modifier. Please give an output variable.');
  end

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
      otherwise
        error('### Unknown value for parameter ''StartPolesOpt''');
    end
  end

  maxiter = find_core(pl, 'maxiter'); % set the maximum number of iterations
  minorder = find_core(pl, 'minorder'); % set the minimum function order
  maxorder = find_core(pl, 'maxorder');% set the maximum function order

  extweights = find_core(pl, 'weights'); % check if external weights are provided
  if isa(extweights, 'ao')
    extweights = extweights.y;
  end
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
      otherwise
        error('### Unknown value for parameter ''weightparam''');
    end
  end

  % decide to plot or not
  plt = find_core(pl, 'plot');
  switch lower(plt)
    case 'on'
      showplot = 1;
    case 'off'
      showplot = 0;
    otherwise
      error('### Unknown value for parameter ''plot''');
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
    otherwise
      error('### Unknown value for parameter ''CONDTYPE''');
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
    otherwise
      error('### Unknown value for parameter ''ForceStability''');
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
    otherwise
      error('### Unknown value for parameter ''AutoSearch''');
  end

  %%%%% End Extract necessary parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  %%%%% Fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%% Fit parameters
  params = struct('spolesopt',spolesopt,...
    'extpoles', extpoles,...
    'Nmaxiter',maxiter,...
    'minorder',minorder,...
    'maxorder',maxorder,...
    'weightparam',weightparam,...
    'extweights', extweights,...
    'plot',showplot,...
    'ctp',ctp,...
    'lrscond',lrscond,...
    'msevar',msevar,...
    'stabfit',stabfit,...
    'dterm',0,...
    'spy',spy,...
    'fullauto',fullauto);

  %%% extracting elements from AOs

  % Finding the index of the first fsdata
  prm = -1;
  for gg = 1:numel(bs)
    if isa(bs(gg).data, 'fsdata')
      prm = gg;
      break
    end
  end
  
  if prm < 0
    error('No input fsdata found');
  end  

  fs = find_core(pl, 'FS');
  if isempty(fs) && isnan(bs(prm).data.fs)
    fs = max(bs(prm).data.x)*2;
  elseif isempty(fs) && ~isnan(bs(prm).data.fs)
    fs = bs(prm).data.fs;
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
      if numel(yt)~=k
        error('Input AOs must have the same number of elements')
      end
      if size(yt,2)>1 % wish to work with columns
        y(:,jj) = yt.';
      else
        y(:,jj) = yt;
      end
      if fs <= max(bs(jj).data.x)*2
        warning('!!! %s cannot fit data when max(f) > fs/2 ', mfilename);
      end
    end
  end
  % reshaping y to contain only Y from fsdata
  y = y(:,idx);

  %%% extracting frequencies
  % Note: all the objects are assumed to caontain the same X (frequencies) values
  f = bs(prm).data.getX;

  %%% Fitting loop
  [res,poles,dterm,mresp,rdl,mse] = utils.math.autodfit(y,f,fs,params);

  %%%%% End Fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  %%%%% Building output AOs with model responses, model parameters are
  % added in the procinfo as parallel bank of miir objects %%%%%%%%%%%%%%%

  %   [a,b] = size(mresp);
  for kk = 1:numel(bs)
    if idx(kk) % build outputs

      % Constructing a vector of miir objects
      %       pfilts = [];
      for hh=1:length(res(:,kk))
        mod(hh,kk) = miir(res(hh,kk), [ 1 -poles(hh)], fs);
        %         mod(hh,kk).addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);
        mod(hh,kk).setName(sprintf('fit(%s)', ao_invars{kk}));
        %         pfilts = [pfilts ft];
      end

      bmod(kk) = filterbank(plist('filters',mod(:,kk),'type','parallel'));
      
      bmod(kk).setName(sprintf('fit(%s)', ao_invars{kk}));
      
      % bmod(kk).addHistory(getInfo('None'), pl, ao_invars(kk), inhist);



      % Output also, model response, residuals and mse in the procinfo
      rsp = mresp(:,kk);
      bs(kk).data.setY(rsp);
      bs(kk).setFs(fs);
      % clear errors
      bs(kk).clearErrors;

      % Set output AO name
      bs(kk).setName(sprintf('fit_resp(%s)', ao_invars{kk}));
      % Add history
      %         bs(kk).addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);

      res_ao = copy(bs(kk),1);
      trdl = rdl(:,kk);
      res_ao.data.setY(trdl);
      res_ao.setFs(fs);

      % Set output AO name
      res_ao.setName(sprintf('fit_residuals(%s)', ao_invars{kk}));
      % Add history
      %         res_ao(kk).addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);

      d = cdata();
      tmse = mse(:,kk);
      d.setY(tmse);
      mse_ao = ao(d);

      % Set output AO name
      mse_ao.setName(sprintf('fit_mse(%s)', ao_invars{kk}));

      procpl = plist('fit_resp',bs(kk),...
        'fit_residuals',res_ao,...
        'fit_mse',mse_ao);

      bmod(kk).setProcinfo(procpl);

    else % in case of non fsdata input
      bmod(kk) = filterbank(mirr());

    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%%%% Set outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set output
  if nargout == 1
    if numel(bs)==1
      bmod.setName(sprintf('fit(%s)', ao_invars{:}));
      bmod.addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);
      varargout{1} = bmod;
    else
      mmod = matrix(bmod);
      mmod.setName(sprintf('fit(%s)', ao_invars{:}));
      mmod.addHistory(getInfo('None'), pl, [ao_invars(:)], [inhists(:)]);
      varargout{1} = mmod;
    end
  else
    % multiple output is not supported
    error('### Multiple output is not supported ###')
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    'specified in ''MINORDER''.']}, ...
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
    '<li>''clin'' linear-spaced complex poles</li></ul>']}, ...
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
    '<li>''ones'' assigns weights equal to 1 to all data.</li>'...
    '<li>''abs'' weighs data with <tt>1./abs(y)</tt></li>'...
    '<li>''sqrt'' weighs data with <tt>1./sqrt(abs(y))</tt></li>']}, ...
    {2, {'ones', 'abs', 'sqrt'}, paramValue.SINGLE});
  pl.append(p);

  % CONDTYPE
  p = param({'CONDTYPE', ['Fit conditioning type. Admitted values are:<ul>'...
    '<li>''MSE'' Mean Squared Error and variation</li>'...
    '<li>''RLD'' Log residuals difference and mean squared error variation</li>'...
    '<li>''RSF'' Residuals spectral flatness and mean squared error variation</li></ul>']}, ...
    {1, {'MSE', 'RLD', 'RSF'}, paramValue.SINGLE});
  pl.append(p);

  % FITTOL
  p = param({'FITTOL', 'Fit tolerance.'}, paramValue.DOUBLE_VALUE(1e-3));
  pl.append(p);

  % MSEVARTOL
  p = param({'MSEVARTOL', ['Mean Squared Error Variation - Check if the<br>'...
    'relative variation of the mean squared error is<br>'...
    'smaller than the value specified. This<br>'...
    'option is useful for finding the minimum of the Chi-squared.']}, ...
    paramValue.DOUBLE_VALUE(1e-2));
  pl.append(p);

  % Plot
  p = param({'Plot', 'Plot results of each fitting step.'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);

  % ForceStability
  p = param({'ForceStability', 'Force poles to be stable'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);

  % CheckProgress
  p = param({'CheckProgress', 'Display the status of the fit iteration.'}, ...
    {2, {'on', 'off'}, paramValue.SINGLE});
  pl.append(p);

  %   pl = plist('FS',[],...
  %   'AutoSearch','on',...
  %   'StartPoles',[],...
  %   'StartPolesOpt','clog',...
  %   'maxiter',50,...
  %   'minorder',2,...
  %   'maxorder',20,...
  %   'weights',[],...
  %   'weightparam','abs',...
  %   'CONDTYPE','MSE',...
  %   'FITTOL',1e-3,...
  %   'MSEVARTOL',1e-2,...
  %   'Plot','off',...
  %   'ForceStability','off',...
  %   'CheckProgress','off');
end
% END


% PARAMETERS:
%
%           'FS'          - It is the sampling frequency. If it is left
%                           empty sampling frequency is searched in the
%                           input AOs or is is calculated as 2 of the
%                           maximum frequency reported in AOs xvalues.
%                           [Default []].
%           'AutoSearch'  - 'on': Parform a full automatic search for the
%                           transfer function order. The fitting
%                           procedure will stop when stop conditions are
%                           satisfied. [Default]
%                           'off': Perform a fitting loop as long as the
%                           number of iteration reach 'maxiter'. The order
%                           of the fitting function will be that
%                           specified in 'minorder'.
%           'StartPoles'  - A vector of starting poles. Providing a fixed
%                           set of starting poles fixes the function
%                           order. If it is left empty starting poles are
%                           internally assigned. [Default []]
%         'StartPolesOpt' - Define the characteristics of internally
%                           assigned starting poles. Admitted values
%                           are:
%                            - 'real' linspaced real poles
%                            - 'c1' complex poles on unit circle. First
%                              method [Default]. See help of
%                              utils.math.startpoles for additional info
%                            - 'c2' complex poles on unit circle. second
%                              method. See help of utils.math.startpoles
%                              for additional info.
%             'maxiter'   - Maximum number of allowed iteration. [Deafult
%                           50].
%                           [default: -inf for each parameter];
%             'minorder'  - Minimum model function order. [Default 2]
%             'maxorder'  - Maximum model function order. [Default 20]
%             'weights'   - A vector with the desired weights. If a single
%                           Ao is input weights must be a Nx1 vector where
%                           N is the number of elements in the input Ao. If
%                           M Aos are passed as input, then weights must
%                           be a NxM matrix. If it is leaved empty weights
%                           are internally assigned basing on the input
%                           parameters. [Default []]
%           'weightparam' - Specify the characteristics of the internally
%                           assigned weights. Admitted values are:
%                           'ones' assigns weights equal to 1 to all data.
%                           'abs' weights data with 1./abs(y) [Default]
%                           'sqrt' weights data with 1./sqrt(abs(y))
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
%           'Plot'        - Plot fit result: 'on' or 'off' [default]
%       'ForceStability'  - Force poles to be stable, values are
%                           'on' or 'off'. [Default 'off']
%         'CheckProgress' - Disply the status of the fit iteration.
%                           Values are 'on and 'off'. [Default 'off']
%
