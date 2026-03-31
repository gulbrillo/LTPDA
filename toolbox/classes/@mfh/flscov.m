% FLSCOV.M - Tool to perform a least square fit in frequency domain.
%
% DESCRIPTION:
%
% CALL:
%       >> pest_obj = flscov([mfh_0, mfh_1, ao_2 ..., mfh_N],pl)
%
%       where the first object of the ao input array is considered to be
%       the output data in the relation
%
%               ao_0 = c_1 * mfh_1.eval() + c_2 * mfh_2.eval() + ... + c_N * mfh_N.eval()
%
%       The c_i are the parameters to be estimated.
%
% PARAMETERS: - pest_obj:   pest object
%             - mfh:        mfh object
%             - pl:         plist
%
%    EXAMPLE: - flscov(obj, plist( ... ))
%
%<a href="matlab:utils.helper.displayMethodInfo('mfh', 'flscov')">ParametersDescription</a>
%
% DV & NK 2015
%
%

function varargout = flscov(varargin)
  
  %%% Check if this is a call for parameters
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
  [mfhin, ~] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  pl         = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  in_mfh = copy(mfhin, nargout);
  
  % Apply the defaults of the plist
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % extract parameters out of the plist
  pTol    = pl.find('p tol');
  maxiter = pl.find('maxiter');
  params  = pl.find('p0');
  w       = pl.find('w');
  
  if isempty(params)
    error('### Please provide a pest object with the corresponding parameters apearing in the MFH objects...')
  elseif numel(params.names) ~= numel(in_mfh)-1
    error('### The number of parameters do not match the imported MFH objects - 1 ...')
  end
  
  % define plists
  psdpl = plist('Win',   pl.find('win'),...
    'navs',  pl.find('navs'),...
    'olap',  pl.find('olap'),...
    'order', pl.find('order'));
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Evaluate the MFH expressions
  data = ao.initObjectWithSize(1, numel(in_mfh));
  for ii=1:numel(in_mfh)
    data(ii) = in_mfh.index(ii).eval();
  end
  
  % Trim data?
  if ~isempty(pl.find('trim'))
    data = split(data, plist('offsets', pl.find('trim')));
  end
  
  % Perform FFT on the time series
  fs = performFFT(data, pl);
  
  plk1 = plist('samples',pl.find('k0'):pl.find('k1'):numel(fs(1).x));
  fs   = select(fs,plk1);
  fpl  = plist('frequencies',pl.find('freqs'));
  
  for mm = 1:size(fs,1)
    for nn = 1:size(fs,2)
      fs(mm,nn) = split(fs(mm,nn), fpl);
    end
  end
  
  % Initialise
  pest_obj = pest.initObjectWithSize(1, maxiter);
  
  % Get the weigths
  w = getWeights(w, fs, params, pl, plk1);
  w = double(w); % get the doubles
   
  % Perform the iterative least squares scheme
  for iter = 1:maxiter
    
    % Do the least squares fit in frequency domain
    [p, invAnm] = lsf(fs, w);
    w0 = w;
    
    % Get correlation
    [ExpCorrC, ~] = utils.math.cov2corr(invAnm);
    
    % Define pest object
    pest_obj(iter) = copy(params);
    pest_obj(iter).setY(p);
    pest_obj(iter).setDy(sqrt(diag(invAnm)));
    pest_obj(iter).setCov(invAnm);
    pest_obj(iter).setCorr(ExpCorrC);
    pest_obj(iter).setYunits(params.yunits);
    pest_obj(iter).setName(sprintf('Parameter'));
    
    % Print message
    printMessage(iter);
    
    % Compute the residuals
    data.simplifyYunits;
    [residuals, res_psd, w] = computeResiduals(data, pest_obj(iter), plk1, pl);
    
    sw = sum(w)/sum(w0);
    fprintf('* chi^2: %s\n', sw);
    % Show results
    table(pest_obj(iter));
    
    % Stopping criterion
    if iter > 1
      % Get the stopping criterion
      dw = abs(sw - 1);
      
      % terminate?
      if all(dw < pTol)
        fprintf('\n')
        fprintf('*** \n')
        fprintf('*** Tolerance criterion satisfied. Stopping re-weighted least squares iterations. *** \n')
        fprintf('*** \n')
        fprintf('\n')
        break
      end
    end % END OF STOPPING CRITERION
    
  end % END OF MAXITER LOOP
  
  % If you want to have a comaprative plot
  if pl.find_core('doplot')
    try
      
      % create a target with the same lenght of residuals
      target_ao = split(in_mfh.index(1).eval(), plist('offsets', pl.find('trim')));
      
      % make the psd of the target
      target_ao_psd = psd(target_ao, psdpl);
      
      % select the frequency bin of the target
      plk_plot = plist('samples',1:pl.find('k1'):numel(target_ao_psd.x));
      target_ao_psd_select = select(target_ao_psd,plk_plot);
      
      % select the frequency range of the analysis
      target_ao_psd_split = split(target_ao_psd_select, fpl);
      
      if ~isempty(pl.find('w'))
        noiseModel    = getmodelout(pl.find('w'), pest_obj(iter));
        noiseResiduas = noiseModel.eval();
        noiseResiduas = split(psd(noiseResiduas.setName('Noise'), psdpl), fpl);
      else
        noiseResiduas = [];
      end
      
      % plot psd of target versus residuals
      iplotPSD(target_ao_psd_split, noiseResiduas, res_psd.setName('Residuals'), ...
        plist('errorbartype','area', 'latexlabels', true, 'show provenance', false));
      
    catch ME
      error('Failed produce plot of the residuals [%s]', ME.message)
    end
  end
  
  % Delete empty pests
  pest_obj(iter+1:end) = [];
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  outModel = getmodelout(in_mfh, pest_obj(end).setName(params.name));
  
  % Create output (set the resulting parameters as constants)
  % outModel.setConstObjects(repmat({[]}, size(outModel.constants)));
  outModel.setParamsToConst(pest_obj(end));
  outModel.setName('model');
  out_pest = pest_obj(end).setModels(outModel);
  
  out_obj = collection(out_pest, residuals);
  out_obj.setProcinfo(plist('history pests', pest_obj(1:iter-1)));
  out_obj = addHistory(out_obj,getInfo('None'), pl, [], [in_mfh.hist]);
  
  % Set outputs
  if nargout > 0
    varargout{1} = out_obj;
  else
    error('### flscov cannot be used as a modifier!');
  end
  
end % END

%--------------------------------------------------------------------------
% get model out
%--------------------------------------------------------------------------
function [modelmfh] = getmodelout(funcs, pest_obj)
  
  % initialise
  modelmfh = funcs.index(1);
  
  for jj = 1:numel(pest_obj.names)
    
    % Define next term
    term = mfh(plist(...
      'built-in',         'custom',...
      'name',             funcs.index(jj+1).name, ...
      'numeric',          false,...
      'func',             [pest_obj.names{jj} '*' funcs.index(jj+1).funcDef], ...
      'params',           pest_obj, ...
      'constants',        funcs.index(jj+1).constants, ...
      'constant objects', funcs.index(jj+1).constObjects));
    
    % Subtract term
    modelmfh = modelmfh - term;
  end
  modelmfh.paramsDef = pest_obj;
end

%--------------------------------------------------------------------------
% Compute the residuals
%--------------------------------------------------------------------------
function [residual, res_psd, w] = computeResiduals(ts, params, plk1, pl)
  
  model = [];
  % get the aos out
  param = ao(params);
  
  try
    % create AOs with the correct yunits and try to compute the residuals
    for ii=2:numel(ts)
      t = param(ii-1).*ts(ii);
      model = model + t;
    end
    
    % Fix y-units
    model.toSI;
    
    % Calculate residuals
    residual = ts(1) - model;
    
    % set name
    residual.setName('Residuals');
    
    % The PSD of the residuals
    freqs = pl.find('frequencies');
    %     res_psd1 = psd(residual, psdpl);
    res_fft = performFFT(residual, pl);
    res_psd = 2.*average(abs(res_fft).^2);
    res_psd = select(res_psd,plk1);
    
    % I need to make sure the frequency vector is the same because
    % it is calculated slightly differently between wosa and fft methods as
    % such there could be a numerical issue
    
    res_psd = split(res_psd, plist('frequencies',freqs));
    
    %     res_psd.setX(fs(1).x);
    
    % Update the weights for the n-th iteration
    if isempty(pl.find('w')) % check if weights have been introduced
      w = double(res_psd);
    else
      w = getWeights(pl.find('w'), res_psd, params, pl, plk1);
      w = double(w);
    end
  catch ME
    error('Failed to compute the residuals [%s]', ME.message)
  end
  
end

%--------------------------------------------------------------------------
% Perform FFT on the time-series
%--------------------------------------------------------------------------
function fs = performFFT(ts, pl)
  
  %   navs  = pl.find('navs');
  %   olap  = pl.find('olap');
  freqs = pl.find('frequencies');
  
  L     = numel(ts(1).y);
  usepl = utils.helper.process_spectral_options(pl,'lin',L);
  nfft  = usepl.getParamValueForParam('NFFT');
  olap  = usepl.getParamValueForParam('OLAP');
  xOlap = round(olap*nfft/100);
  
  % Compute segment details
  nSegments = fix((L-xOlap)./(nfft - xOlap));
  
  % Compute start and end indices of each segment
  segmentStep   = nfft-xOlap;
  segmentStarts = 1:segmentStep:nSegments*segmentStep;
  segmentEnds   = segmentStarts+nfft-1;
  
  % get # of time-series
  N_ts = numel(ts);
  ts_s = ao.initObjectWithSize(N_ts, nSegments);
  
  for ii = 1:nSegments
    spl      = plist('samples', [segmentStarts(ii) segmentEnds(ii)]);
    ts_s(:,ii) = split(ts, spl);
  end
  
  fs = performFFTcore(ts_s, N_ts, nSegments, freqs, pl);
  
end

%--------------------------------------------------------------------------
% Get the weights function
%--------------------------------------------------------------------------
function w = getWeights(w, fs, params, pl, plk1)
  
  % Get the psd plist 
  psdpl = subset(pl, {'win','olap','navs'});
  
  if isempty(w)
    w = ones(1,numel(double(fs(1))))'; % initial weights
  else
    switch class(w)
      case 'ao'
        if isa(w.data, 'tsdata')
          w = psd(w, psdpl);
        end
        w = split(w, plist('frequencies',pl.find('freqs')));
        w = interp(w, plist('vertices', fs(1).x));
      case 'mfh'
        % Evaluate the MFH expressions
        nm = getmodelout(w, params);
        w  = nm.eval();
        w  = psd(w, psdpl);
        w  = select(w, plk1);
        w  = split(w, plist('frequencies',pl.find('freqs')));
        w  = interp(w, plist('vertices', fs(1).x));
    end
  end
  
end

%--------------------------------------------------------------------------
% Print message at each loop function
%--------------------------------------------------------------------------
function printMessage(iter)
  
  fprintf(' \n')
  fprintf('************* Finished loop %d ************* \n', iter)
  fprintf(' \n')
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  
  p = param({'P0', 'A cell pest object containing the definition of the parameters.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('x0');
  p.addAlternativeKey('params');
  pl.append(p);
  
  p = param({'FREQUENCIES','The frequency range. Must be a [2x1] array with the minimum and maximum frequencies of the analysis.'},  paramValue.DOUBLE_VALUE([]));
  p.addAlternativeKey('f');
  p.addAlternativeKey('freqs');
  pl.append(p);
  
  p = param({'NAME','The name of the result of the fit.'},  paramValue.STRING_VALUE('Frequency domain chi^2 fit'));
  pl.append(p);
  
  p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
  pl.append(p);
  
  p = param({'NAVS', 'The Number of averages for the PSD of the noise.'}, 10);
  pl.append(p);
  
  p = param({'OLAP', 'The segment percent overlap [-1 == take from window function]'}, -1);
  pl.append(p);
  
  p = param({'NOISE MODEL',['The given noise model. It may be a) an AO time-series with the appropriate Y units, b) '...
    'an AO frequency-series of the correct size (NoutputsXNoutputs), c) a SMODEL (function of freqs) '...
    'of the correct size (NoutputsXNoutputs) d) a MFH object. ']},  paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'INTERPOLATION METHOD', 'The interpolation method for the computation of the inverse cross-spectrum matrix.'}, ...
    {2, {'nearest', 'linear', 'spline', 'pchip', 'cubic', 'v5cubic'}, paramValue.SINGLE});
  pl.append(p);
  
  p = param({'ORDER',['The order of segment detrending:<ul>', ...
    '<li>-1 - no detrending</li>', ...
    '<li>0 - subtract mean</li>', ...
    '<li>1 - subtract linear fit</li>', ...
    '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
  p.val.setValIndex(-1);
  pl.append(p);
  
  p = param({'DOPLOT', 'True-False flag to plot the residual time series.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = plist({'BIN DATA','Set to true to re-bin the measured noise data.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = plist({'FIT NOISE MODEL','Set to true to attempt a fit on the noise spectra using the ''polyfitSpectrum'' function.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = plist({'POLYNOMIAL ORDER','The order of the polynomial to be used in the ''polyfitSpectrum'' function.'}, paramValue.DOUBLE_VALUE(-10:10));
  pl.append(p);
  
  p = param({'k0','The first FFT coefficient of the analysis. All K<K1 coefficients are dropped.'},  paramValue.DOUBLE_VALUE(5));
  pl.append(p);
  
  p = param({'k1','The k1 coefficient to downsample in frequency domain. More info found in Phys. Rev. D 90, 042003. If left empty, all the spectra is used.'},  paramValue.DOUBLE_VALUE(4));
  pl.append(p);
  
  p = param({'P TOL', 'The tolerance for terminating the outer loop. The iterations will stop if the change in the p0-p0_previous is less than this value.'}, paramValue.DOUBLE_VALUE(1e-6));
  pl.append(p);
  
  p = param({'MAXITER', 'The maximum number of iterations of the outer chi^2 loop.'}, paramValue.DOUBLE_VALUE(30));
  pl.append(p);
  
  p = param({'WEIGHTS', 'A given frequency or time series to be used as initial weights in the calculation.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('W');
  pl.append(p);
  
end

% END
