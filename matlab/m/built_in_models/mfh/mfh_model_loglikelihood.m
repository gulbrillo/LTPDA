% mfh_model_loglikelihood constructs a log-likelihood function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_LOGLIKELIHOOD constructs a MFH likelihood function from 
%                                      a given set of predefined formulations. 
%
% For the standard Gaussian approximation of a log-likelihood we write
%
%         L = Sum[(data-model)^* x S^-1 x (data-model)],
%
% where S^-1 is the inverse cross-spectrum matrix of the noise. The MFH
% model (plist key 'Time Series MFH') should correspond to the 
% expression of (data-model).
%
% The built-in model assumes that the data-model is a single MFH object
% that depends on a given parameter set 'p' ('p' is used as the inputs),
% while the noise ('NOISE MODEL' plist key) can be:
%
% a) AO tsdata noise time series. The PSD is computed based on the input
%    plist, and then the inverse cross-spectrum matrix is derived.
%
% b) AO fsdata frequency series. It is assumed that the fsdata are in the
%    correct format, so they are just copied and interpolated to the signal
%    frequencies.
%
% c) SMODEL array. The SMODELs are assumed that they describe smooth models
%    of the PSD of the noise. They are evaluated at the signal frequencies
%    and then the inverse cross-spectrum matrix is computed.
%
% For more info check the MCMC.computeICSMatrix function.
%
%
%
%
%                                      
% CAUTION: It is possible to form the joint log-likelihood of joint 
%          experiments/investigations, provided that the system does not 
%          change. The syntax must be as follows:
%
% The number of experiments are taken from the number of columns of the   
% given MFH time-series function. The number of channels of the
% investigation are quivalent to the number of rows of the MFH. for example:
%
% If we assume that the MFH time series to feed the log-likelihood look like
% 
% data_channel1 = [data_channel1_exp1, data_channel1_exp2]; 
% data_channel2 = [data_channel2_exp1, data_channel2_exp2];
%
% Then:
%
% my_mhf_objects = [data_channel1; data_channel2];
%
% llhfc = mfh(plist('built-in',        'loglikelihood', ...
%                   'name',            'lambda', ...
%                   'Time Series MFH', my_mhf_objects,... 
%                   'p0',              iniVals));
%
%    CALL: a = mfh(plist('built-in', 'loglikelihood'), pl);
%
% OUTPUTS: mdl - an MFH object with the desired properties.
%
% EXAMPLE: a =  mfh(plist('built-in', 'loglikelihood', 'version', 'ao', 'key', value));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_loglikelihood')">Model Information</a>
%
% NK 2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_loglikelihood(varargin)
  
  varargout = utils.models.mainFnc(varargin(:), ...
                                                mfilename, ...
                                                @getModelDescription, ...
                                                @getModelDocumentation, ...
                                                @getVersion, ...
                                                @versionTable, ...
                                                @getPackageName);
  
end

%--------------------------------------------------------------------------
% AUTHORS EDIT THIS PART
%--------------------------------------------------------------------------

function desc = getModelDescription
  desc = 'Constructs a @mfh object of a log-likelihood function. ';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'Constructs a @mfh object of a log-likelihood function to a given time-series data-set. ' ...
    'The MFH time-series model must have been created with the appropriate '...
    'plist keys. The ''CORE'' version of the ''loglikelihood'' model must be used ' ...
    'to MFH that is both ''CORE'' and ''NUMERIC''. The ''AO'' version on the '...
    'other hand must be applied to ''tsdata''.'
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'chi2',         @chi2, ...
    'chi2 ao',      @chi2ao ...
    'log',          @log ...
    'whittle',      @whittle ...
    'noise fit v1', @noiseFit_v1 ...
    'student-t',    @student ...
    'td core',      @td_core ...
    'td ao',        @td_ao ...
    'hyperbolic',   @hyper ...
    };
  
end


% CHI2
%
function varargout = chi2(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses the ''core'' LTPDA functions for faster computations.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl          = copy(varargin{1}, 1);
  doplot      = pl.find('doplot');
  
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES'))
    error('### The key ''TS FH'', ''P0'' and ''FREQUENCIES'' must not be empty...');
  end
    
  % Compute inverse cross-spectrum noise matrix                    
  S = icsm(pl);
  
  % the main model of the log-likelihood
  model = pl.find('Time Series MFH');
  
  % Evaluating at p0 - checking the model
  checkModel(model, pl.find('p0'), pl.find('fs'), pl.find('yunits'));
  
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'core',...
                        'ts fh',        model,... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           pl.find('P0'),...
                        'fs',           pl.find('FS'),...
                        'win',          pl.find('WIN')));
  
  % evaluate and plot
  if doplot
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, pl.find('P0'))
  end
                      
  % Put noise into a structure array
  ICSM = MCMC.ao2strucArrays(plist('S', S,'Nexp', numel(S)));
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_core(fft_signals, p, ICSM, k0)', ...
                'params',           p0, ...
                'inputs',           'p', ...
                'constants',        {'ICSM', 'fft_signals', 'k0'}, ...
                'constant objects', {ICSM, fft_signals, pl.find('k0')}));
  
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals));
  
end

% HYPERBOLIC
%
function varargout = hyper(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % NOISE PARAMETERS INDEX
        p = param({'NOISE PARAMETERS INDEX','The index of the noise parameters.'}, paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('noise parameter indices');
        p.addAlternativeKey('nindex');
        pl.append(p);
        
        % parameter 'ALPHA'
        p = param({'ALPHA','.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'DELTA'
        p = param({'DELTA','.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses the ''core'' LTPDA functions for faster computations.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl     = copy(varargin{1}, 1);
  doplot = pl.find('doplot');
  p0     = pl.find('P0');
  a      = pl.find('alpha');
  delta  = pl.find('delta');
  np     = pl.find('nindex');
  
  % Checking the parameters
  if (isempty(delta) || isempty(a)) && (isempty(p0.find('alpha')) || isempty(p0.find('delta')))
    error(['### Please check inputs again. If the ''ALPHA'' anf ''DELTA'' coefficients are to be '...
           'considered unknown, they must appear in the definition pest object.'])
  end
  
  if isempty(pl.find('Time Series MFH')) || isempty(p0) || isempty(pl.find('FREQUENCIES'))
    error('### The key ''TS FH'', ''P0'' and ''FREQUENCIES'' must not be empty...');
  end
    
  % Compute inverse cross-spectrum noise matrix                    
  S = icsm(pl);
  
  % the main model of the log-likelihood
  model = pl.find('Time Series MFH');
  
  % Evaluating at p0 - checking the model
  checkModel(model, pl.find('p0'), pl.find('fs'), pl.find('yunits'));
  
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'core',...
                        'ts fh',        model,... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           pl.find('P0'),...
                        'fs',           pl.find('FS'),...
                        'win',          pl.find('WIN')));
  
  % evaluate and plot
  if doplot
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, pl.find('P0'))
  end
                      
  % Put noise into a structure array
  ICSM = MCMC.ao2strucArrays(plist('S', S,'Nexp', numel(S)));
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_hyper(fft_signals, p, ICSM, k0, a, d, np)', ...
                'params',           p0, ...
                'inputs',           'p', ...
                'constants',        {'ICSM', 'fft_signals', 'k0', 'a', 'd', 'np'}, ...
                'constant objects', {ICSM, fft_signals, pl.find('k0'), a, delta, np}));
  
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals));
  
end

% CHI2 AO
%
function varargout = chi2ao(varargin)
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses AO methods that make the computations slower.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl     = copy(varargin{1}, 1);
  doplot = pl.find('doplot');
  
  % sanity checks
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES'))
    error('### The key ''TS FH'', ''P0'' and ''FREQUENCIES'' must not be empty...');
  end
  
  % Compute inverse cross-spectrum noise matrix
  S = icsm(pl);
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Evaluating at p0 - checking the model
  checkModel(pl.find('Time Series MFH'), p0, pl.find('fs'), pl.find('yunits'));
    
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'ao',...
                        'ts fh',        pl.find('Time Series MFH'),... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           pl.find('P0'),...
                        'win',          pl.find('WIN')));
  
  % evaluate and plot
  if doplot
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, pl.find('P0'))
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood(fft_signals, p, noise, k0)', ...
                'inputs',           'p', ...
                'params',           p0, ...
                'constants',        {'noise', 'fft_signals', 'k0'}, ...
                'constant objects', {S, fft_signals, pl.find('k0')}));
  
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals));
  
end

% LOGARITHMIC
%
function varargout = log(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'FREQUENCIES'
        p = param({'FREQUENCIES','The frequency range.'},  paramValue.DOUBLE_VALUE([]));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'FUNC NAME','The name of the likelihood function handle.'},  paramValue.STRING_VALUE('LLH'));
        pl.append(p);
        
        % parameter 'Time Series MFH'
        p = param({'TIME SERIES MFH','The time series function handles to perform the FFT. Must be in an array.'},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('MODEL');
        pl.append(p);
        
        % parameter 'P0'
        p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('X0');
        p.addAlternativeKey('paramVals');
        pl.append(p);
        
        % parameter 'TRIM'
        p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([100 -100]));
        pl.append(p);
        
        % parameter 'WIN'
        p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
        pl.append(p);
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'k0'
        p = param({'k0','The first FFT coefficient of the analysis.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'k1'
        p = param({'k1','The k1 coefficient to downsample in frequency domain. More info found in Phys. Rev. D 90, 042003. Default value is 1 (one), in which case all the spectra is used.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'Navs'
        p = param({'NAVS', 'The Number of averages to be considered for the time-series data.'}, 10);
        pl.append(p);
        
        % parameter 'OLAP'
        p = param({'OLAP', 'The segment percent overlap [-1 == take from window function]'}, -1);
        pl.append(p);
        
        % parameter 'SEGMENTED'
        p = param({'SEGMENTS', 'A custom timespan object, in case of user-split data. Data must be evenly sampled and each segment must have the same length. Necessary for this kind of analysis is the filling of the ''T0'' and ''TOFFSET'' plist keys.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 't0'
        p = param({'t0', 'The t0 of the time series in the MFH model. Necessary to reconstruct the time vector and split the data.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'toffset'
        p = param({'toffset', 'The toffset of the time series in the MFH model. Necessary to reconstruct the time vector and split the data.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % Order, N
        p = param({'ORDER',['The order of segment detrending:<ul>', ...
          '<li>-1 - no detrending</li>', ...
          '<li>0 - subtract mean</li>', ...
          '<li>1 - subtract linear fit</li>', ...
          '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
        p.val.setValIndex(1);
        pl.append(p);
        
        % parameter 'yunits'
        p = param({'YUNITS', 'The Y units of the noise time series, in case the MFH object is a ''core'' type.'}, paramValue.STRING_VALUE('m s^-2'));
        pl.append(p);
        
        % parameter 'DOPLOT'
        p = param({'DOPLOT', 'True-False flag to plot the FFT of the signal time-series.'}, paramValue.TRUE_FALSE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = ['A) This version uses the ''core'' LTPDA functions for faster computations. '...
                        'B) It is based in the Logarithmic Log-likelihood (LL) explaned in http://arxiv.org/abs/1404.4792.'];
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl = copy(varargin{1}, 1);
  
  % Some sanity checks
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES'))
    error('### The key ''TS FH'', ''P0'' and ''FREQUENCIES'' must not be empty...');
  end
  
  if  size(pl.find('Time Series MFH'),1) > 1
    error('### This version of the log-likelihood works only with one channel for now... Sorry...');
  end
  
  % Check parameters for the segmented analysis.
  segs    = pl.find('SEGMENTS');
  t0      = pl.find('T0');
  toffset = pl.find('TOFFSET');
  doplot  = pl.find('DOPLOT');
  olap    = pl.find('OLAP');
  
  % Chek k0, k1
  k0        = pl.find('k0');
  k1        = pl.find('k1');
  if isempty(k0) || isempty(k1)
    error('### The ''K0'' and ''K1'' must be integer values >= 1 ...')
  end
  
  % Some checks
  if ~isempty(segs) && (isempty(t0) || isempty(toffset))
    error('### For this kind of segmented analysis, the keys ''T0'' and ''TOFFSET'' are required...')
  end
  if ~isempty(segs) && ~all(class(segs) == 'timespan')
    error('### The ''SEGMENTS'' key accepts only timespan objects... ')
  end
  if isempty(olap)
    olap = -1;
  end
  
  % get the time-series
  model = pl.find('MODEL');
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Evaluating at p0 - checking the model
  outModel = checkModel(model, p0, pl.find('fs'), pl.find('yunits'));
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_core_log(ts, p, Ns, olap, freqs, trim, win, k0, k1, fs, dt, segments, t0, toff)', ...
                'params',           p0, ...
                'inputs',           'p', ...
                'constants',        {'ts', 'Ns', 'olap', 'freqs', 'trim', 'win', 'k0', 'k1', 'fs', 'dt', 'segments', 't0', 'toff'}, ...
                'constant objects', {model, pl.find('Navs'), olap,...
                                     pl.find('FREQUENCIES'), pl.find('TRIM'),...
                                     pl.find('WIN'), k0, k1, pl.find('FS'), pl.find('order'), segs, t0, toffset}));
  
  % evaluate and plot
  if doplot
    try
      Smodel = split(psd(outModel, plist('win', pl.find('win'), 'navs', pl.find('navs'), 'olap', olap)), plist('frequencies', pl.find('FREQUENCIES')));
      for jj=1:numel(Smodel)
        Smodeldouble = double(Smodel(jj));
        model_name   = model.index(jj).name;
        Smodel(jj)   = ao(plist('type', 'fsdata', 'yvals', Smodeldouble(k0:k1:end), 'dy', Smodel(jj).dy(k0:k1:end), 'xvals', Smodel(jj).x(k0:k1:end), 'yunits', Smodel(jj).yunits, 'xunits', 'Hz', 'name', sprintf('PSD(%s)', model_name)));
      end
      hfig = iplotPSD(Smodel, plist('titles', 'The PSD of the experiments time series.', 'errorbartype', 'area'));
      % Rename figure
      set(hfig, 'Name', 'PSD of the time series','NumberTitle','off')
    catch Me
      warning('### Could not plot the PSD of the model calculated at P0 ... Error: [%s]', Me.message)
    end
  end
  
  varargout{1} = L;
  
end

% NOISE FIT VERSION 1
%
function varargout = noiseFit_v1(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % BIN GROUPS
        p = param({'BIN GROUPS',['A numerical vector that denotes to the start and end frequency value that corresponds to the given '...
                           'frequency block amplitude. The min(freqs) and max(freqs) is taken from the key ''FREQUENCIES''. Each ETA amplitude value is automatically taken into account in the likelihood '...
                           'function as in ''Phys. Rev. D 80, 063007 (2009)'' and ''Phys. Rev. D 88, 084044 (2013)''.']},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % NOISE PARAMETERS INDEX
        p = param({'NOISE PARAMETERS INDEX','The index of the noise parameters.'}, paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('noise parameter indices');
        p.addAlternativeKey('eta indices');
        pl.append(p);
        
        % P0 NOISE
        p = plist({'P0 NOISE','The initial guess for the noise parameters. '}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % ALPHA
        p = plist({'ALPHA','The scale parameter for the prior distributions of the noise parameters. Applied to the case of the ''NOISE FIT V1'' likelihood. '}, paramValue.DOUBLE_VALUE(1e4));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = ['A) This version uses the ''core'' LTPDA functions for faster computations. '...
                        'B) Also, it multiplies the noise with a certain vector of ''eta'' amplitudes, '...
                        'given the input frequencies from the plist key ''ETAS''. '...
                        'For more information, please check PRD 80, 063007 (2009) and PRD 88, 084044 (2013).'];
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl     = copy(varargin{1}, 1);
  doplot = pl.find('doplot');
  
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES')) || isempty(pl.find('NOISE PARAMETERS INDEX'))
    error('### The key ''TS FH'', ''P0'', ''ETAS'', ''BIN GROUPS'' and ''FREQUENCIES'' must not be empty...');
  end
  
  if ~isempty(pl.find('BIN GROUPS')) && (min(pl.find('BIN GROUPS')) < min(pl.find('FREQUENCIES')) || max(pl.find('BIN GROUPS')) > max(pl.find('FREQUENCIES')))
    error('### Please check again the ''FREQUENCIES'' and ''BIN GROUPS'' plist keys...')
  end
  
  if  size(pl.find('Time Series MFH'),1) > 1
    error('### This version of the log-likelihood works only with one channel for now... Sorry...');
  end
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  if ~isempty(p0)
    p0.setName('p');
  end
    
  % Compute inverse cross-spectrum noise matrix
  S = icsm(pl);
  
  % Evaluating at p0 - checking the model
  checkModel(pl.find('Time Series MFH'), pl.find('p0'), pl.find('fs'), pl.find('yunits'));
  
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'core',...
                        'ts fh',        pl.find('Time Series MFH'),... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           pl.find('P0'),...
                        'fs',           pl.find('FS'),...
                        'BIN GROUPS',   pl.find('BIN GROUPS'),...
                        'win',          pl.find('WIN')));
  
  % evaluate and plot
  if doplot
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, pl.find('P0'))
  end
                      
  % Put noise into a structure array
  ICSM = MCMC.ao2strucArrays(plist('S', S,'Nexp', numel(S)));
  
  % Get the vectors
  eta_vectors = fft_signals.index(1).procinfo.find('eta vectors');
  
  try
    % Define prior densities
    expr_priors = [];
    a           = pl.find('alpha');
    Nbins       = zeros(1, numel(eta_vectors{1}));
    nc          = [];
    noiseParams = numel(eta_vectors{1});
    np          = pl.find('NOISE PARAMETERS INDEX');
    if max(np) == numel(p0)
      p0(np) = [];
    end
    nparams     = abs(numel(double(p0))-numel(eta_vectors{1}));
    p0_n        = pl.find('p0 noise');
    if isempty(p0_n)
      p0_n = ones(1, noiseParams);
    end

    % Create the prior distributions for the noise parameters
    for ii =1:noiseParams
      Nbins(ii)   = numel(eta_vectors{1}{ii});
      expr_priors = [expr_priors, sprintf('-0.5*double((p(%d + %d)-%15.20f)./(%d*1/sqrt(%d))).^2', nparams, ii, p0_n(ii), a, Nbins(ii))];
      nc          = [nc 1/(a.*sqrt(Nbins(ii)))];
    end

    prior = mfh(plist('func',    expr_priors,...
                      'numeric', true,...
                      'inputs',  'p'));

    % Create Gaussian proposal distribution
    nc = diag(nc);
  catch ME 
    fprintf('### Failed to define a prior distribution from the data given. It must be defined by hand... \n Error: [%s]', ME.message);
    prior = [];
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_core_noiseFit_v1(fft_signals, p, ICSM, etas, np, k0)', ...
                'inputs',           'p', ...
                'params',           p0, ...
                'constants',        {'ICSM', 'fft_signals', 'etas', 'np', 'k0'}, ...
                'constant objects', {ICSM, fft_signals, eta_vectors, np, pl.find('k0')}));
  
  % Create output, add the proposal and prior distributions to the procinfo            
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals,...
                                     'prior',       prior, ...
                                     'noise cov',   nc));
  
end

% STUDENT-T
%
function varargout = student(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'NU'
        p = param({'NU',['The ''degrees of freedom'' parameter for the student-t distribution, as proposed in PRD 84, 122004 (2011). ', ...
                         'There are three posibilities to ad th nu coefficient. The ''COMMON'' choise, follows the simplified logic ', ...
                         'that the noise frequency bins follow the same distribution. The second ''BY BIN GROUPS'' considers common ',...
                         'value for the coefficient for neighboring frequency bins, defined with the key ''BIN GROUPS''. The last choice ',...
                         'considers a different degree of freedom for each frequency bin.']},  ...
                  {1, {'common','by bins groups','by bins'}, paramValue.SINGLE});
        pl.append(p);
        
        % parameter 'ERROR RATIO'
        p = param({'ERROR RATIO', 'The percentage of error allowed for each frequency bin (or group of bins).'}, paramValue.DOUBLE_VALUE(0.5));
        pl.append(p);
        
        % NOISE PARAMETERS INDEX
        p = plist({'NOISE PARAMETERS INDEX','The index of the noise parameters. It must be in consistence with the choice of the ''NU'' key.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'BIN GROUPS'
        p = param({'BIN GROUPS',['A numerical vector that denotes to the start and end frequency value that corresponds to the given '...
                                 'frequency block amplitude. The min(freqs) and max(freqs) is taken from the key ''FREQUENCIES''. \n', ...
                                 'If is a single double, then it is assumed that all the bin coefficients are common. ']},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = ['A) This version uses the ''core'' LTPDA functions for faster computations. '...
                        'B) It is based in the student-t Log-likelihood introduced in PRD 84, 122004 (2011).'];
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl = copy(varargin{1}, 1);
  
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES'))
    error('### The key ''TS FH'', ''P0'' and ''FREQUENCIES'' must not be empty...');
  end
  
  if  size(pl.find('Time Series MFH'),1) > 1
    error('### This version of the log-likelihood works only with one channel for now... Sorry...');
  end
  
  % gt the nu coefficients
  nu        = pl.find('NU');
  bingroups = pl.find('BIN GROUPS');
  
  if strcmpi(nu, 'by bins groups') && (min(bingroups) < min(pl.find('FREQUENCIES')) || max(bingroups) > max(pl.find('FREQUENCIES')))
    
    error('### Please check again the ''FREQUENCIES'' and ''NU'' plist keys...')
  
  elseif strcmpi(nu, 'common') && (~isempty(bingroups) || numel(pl.find('BIN GROUPS')) > 1)
    
    error('### Please check again the ''FREQUENCIES'' and ''NU'' plist keys...')
    
  end
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Compute inverse cross-spectrum noise matrix   
  S = icsm(pl);
  
  % Evaluating at p0 - checking the model
  checkModel(pl.find('Time Series MFH'), p0, pl.find('fs'), pl.find('yunits'));
  
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'core',...
                        'S',            S,...
                        'ERROR RATIO',  pl.find('ERROR RATIO'),...
                        'ts fh',        pl.find('Time Series MFH'),... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           p0,...
                        'fs',           pl.find('FS'),...
                        'nu',           pl.find('NU'),...
                        'BIN GROUPS',   pl.find('BIN GROUPS'),...
                        'win',          pl.find('WIN')));
 
  % evaluate and plot
  if pl.find('doplot');
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, p0)
  end
                      
  % Put noise into a structure array
  if ~strcmpi(nu, 'by bins')
    % error('### Sorry, not implemented yet. For now only one common nu coefficient is allowed...');
    ICSM = MCMC.ao2strucArrays(plist('S', S,'Nexp', numel(S)));                    
  else
    ICSM = MCMC.ao2strucArrays(plist('S', fft_signals.index(1).procinfo.find('S'),'Nexp', numel(S))); 
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_core_student(fft_signals, p, ICSM, nu, np,k0)', ...
                'inputs',           'p', ...
                'params',           p0, ...
                'constants',        {'ICSM', 'fft_signals', 'nu', 'np', 'k0'}, ...
                'constant objects', {ICSM, fft_signals, fft_signals.index(1).procinfo.find('nu vectors'), pl.find('NOISE PARAMETERS INDEX'), pl.find('k0')}));
  
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals));
  
end

% Time Domain CORE
%
function varargout = td_core(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();

        % parameter 'NAME'
        p = param({'FUNC NAME','The name of the likelihood function handle.'},  paramValue.STRING_VALUE('LLH'));
        pl.append(p);
        
        % parameter 'Data'
        p = param({'DATA',['The measured data.  In contrast to the frequency domain likelihoods, ',...
                           'the model and the data to form the (data-model)^2 chi^2 cost function are required.']},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'Time Series MFH'
        p = param({'MODEL',['The model function handles. Must be in an array. In contrast to the frequency domain likelihoods, ',...
                            'the model and the data to form the (data-model)^2 chi^2 cost function are required.']},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('Time series MFH');
        pl.append(p);
        
        % parameter 'P0'
        p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('X0');
        p.addAlternativeKey('paramVals');
        pl.append(p);
        
        % parameter 'transform'
        p = param({'TRANSFORM', 'A list of transformations to be applied to the inputs before evaluating the expression.'}, paramValue.EMPTY_CELL);
        p.addAlternativeKey('transformations');
        pl.append(p);
        
        % parameter 'DY'
        p = param({'DY', 'The errors ''dy'' of the data, to be taken into account in the likelihood function.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses the ''core'' LTPDA functions for faster computations.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl  = copy(varargin{1}, 1);
  
  if isempty(pl.find('DATA')) || isempty(pl.find('MODEL')) || isempty(pl.find('P0')) 
    error('### The keys ''MODEL'', ''DATA'' and ''P0'' must not be empty...');
  end
    
  % Get the data-model MFH
  mdl = pl.find('Model');
  dy  = pl.find('DY');
  y   = pl.find('DATA');
  
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Evaluating at p0 - checking the model
  checkModel(mdl, pl.find('p0'), y.fs, y.yunits); 
  
  % Cost function definition
  L = mfh(plist(...
              'name',             pl.find('FUNC NAME'),...
              'func',             'loglikelihood_core_td(mdl, data, p, dy)', ...
              'inputs',           'p', ...
              'params',           p0, ...
              'constants',        {'mdl', 'data', 'dy'}, ...
              'constant objects', {mdl, double(y), double(dy)}, ...
              'subfuncs',         mdl));
  
  varargout{1} = L.setProcinfo(plist('model', mdl));
  
end

% Time Domain CORE
%
function varargout = td_ao(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();

        % parameter 'NAME'
        p = param({'FUNC NAME','The name of the likelihood function handle.'},  paramValue.STRING_VALUE('LLH'));
        pl.append(p);
        
        % parameter 'Data'
        p = param({'DATA',['The measured data.  In contrast to the frequency domain likelihoods, ',...
                           'the model and the data to form the (data-model)^2 chi^2 cost function are required.']},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'Time Series MFH'
        p = param({'MODEL',['The model function handles. Must be in an array. In contrast to the frequency domain likelihoods, ',...
                            'the model and the data to form the (data-model)^2 chi^2 cost function are required.']},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('Time series MFH');
        pl.append(p);
        
        % parameter 'P0'
        p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
        p.addAlternativeKey('X0');
        p.addAlternativeKey('paramVals');
        pl.append(p);
        
        % parameter 'transform'
        p = param({'TRANSFORM', 'A list of transformations to be applied to the inputs before evaluating the expression.'}, paramValue.EMPTY_CELL);
        p.addAlternativeKey('transformations');
        pl.append(p);
        
        % parameter 'DY'
        p = param({'DY', 'The errors ''dy'' of the data, to be taken into account in the likelihood function.'}, paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses the ''core'' LTPDA functions for faster computations.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl  = copy(varargin{1}, 1);
  
  if isempty(pl.find('DATA')) || isempty(pl.find('MODEL')) || isempty(pl.find('P0')) 
    error('### The keys ''MODEL'', ''DATA'' and ''P0'' must not be empty...');
  end
    
  % Get the data-model MFH
  mdl = pl.find('Model');
  dy  = pl.find('DY');
  y   = pl.find('DATA');
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Evaluating at p0 - checking the model
  checkModel(mdl, p0, y.fs, y.yunits);  
  
  % Cost function definition
  L = mfh(plist(...
              'name',             pl.find('FUNC NAME'),...
              'func',             'loglikelihood_core_td(mdl, data, p, dy)', ...
              'inputs',           'p', ...
              'params',           p0, ...
              'constants',        {'mdl', 'data', 'dy'}, ...
              'constant objects', {mdl, double(y), double(dy)}, ...
              'subfuncs',         mdl));
  
  varargout{1} = L.setProcinfo(plist('model', mdl));
  
end

% WHITTLE
%
function varargout = whittle(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The static factory plist for LLH
        pl = plist.LLH_PLIST;  
        
        % parameter 'FS'
        p = param({'FS','For the case of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = ['The ''Whittle'' approximation to the likelihood function (see Journal of the Royal Statistical Society. ', ...
                        'Series B, 19(1):38?63,).  This version uses the ''core'' LTPDA functions for faster computations.'];
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl      = copy(varargin{1}, 1);
  doplot  = pl.find('doplot');
  noise   = pl.find('NOISE MODEL');
  % prepare an initial parameter guess, either from the user input, or from
  % the model defaults, if they exist.
  p0 = pl.find('p0');
  if isempty(p0)
    p0 = model(1).paramsDef;
  end
  
  if ~isempty(p0)
    p0.setName('p');
  end
  
  % Check the class of the noise model
  if ~isa(noise, 'mfh')
    error('### The noise must be an MFH model in order to be evaluated at each evaluation of this version of the likelihood function...')
  end
  
  if isempty(pl.find('Time Series MFH')) || isempty(pl.find('P0')) || isempty(pl.find('FREQUENCIES')) || isempty(noise)
    error('### The key ''TS FH'', ''P0'', ''NOISE MODEL'' and ''FREQUENCIES'' must not be empty...');
  end
  
  if numel(pl.find('Time Series MFH')) >1
    error('### Not implemented yet for multiple experiments and data channels yet. Sorry ...')
  end
    
  % Compute inverse cross-spectrum noise matrix                    
  S = icsm(pl);
  
  % Evaluating at p0 - checking the model
  checkModel(pl.find('Time Series MFH'), p0, pl.find('fs'), pl.find('yunits'));
  
  % Evaluating the NOISE model at p0 - checking the model
  checkModel(noise, p0, pl.find('fs'), pl.find('yunits'));
  
  % Define the FFT of the experiment time-series MFH
  fft_signals = mfh(plist(...
                        'built-in',     'fft_signals', ...
                        'name',         'fft_signals', ...
                        'version',      'core',...
                        'ts fh',        pl.find('Time Series MFH'),... 
                        'trim',         pl.find('TRIM'),...
                        'frequencies',  pl.find('FREQUENCIES'),...
                        'p0',           p0,...
                        'fs',           pl.find('FS'),...
                        'win',          pl.find('WIN')));
  
  % evaluate and plot
  if doplot
    plotFFTsignals(pl.find('Time Series MFH'), S, fft_signals, pl.find('P0'))
  end
  
  % Create a proper MFH of the log-likelihood function
  L = mfh(plist('name',             pl.find('FUNC NAME'),...
                'func',             'loglikelihood_core_whittle(fft_signals, noise_model, p, Ns, olap, freqs, trim, win, k0, fs, dt, fsigs)', ...
                'inputs',           'p', ...
                'params',           p0, ...
                'constants',        {'fft_signals', 'noise_model', 'Ns', 'olap', 'freqs', 'trim', 'win', 'k0', 'fs', 'dt', 'fsigs'}, ...
                'constant objects', {fft_signals, noise, pl.find('Navs'), pl.find('OLAP'),pl.find('FREQUENCIES'), pl.find('TRIM'),...
                                     pl.find('WIN'), pl.find('k0'), pl.find('FS'), pl.find('order'), fft_signals.procinfo.find('freqs')}));
  
  varargout{1} = L.setProcinfo(plist('S',           S,...
                                     'fft_signals', fft_signals));
  
end

%--------------------------------------------------------------------------
% ESTIMATE INVERSE CROSS-SPECTRUM MATRIX
%--------------------------------------------------------------------------
function S = icsm(pl)

  fs        = pl.find('FS');
  navs      = pl.find('NAVS');
  olap      = pl.find('OLAP');
  ordr      = pl.find('ORDER');
  acc_mfh_n = pl.find('NOISE MODEL');
  yun       = pl.find('YUNITS');
  acc_mfh   = pl.find('Time Series MFH');
  trim      = pl.find('TRIM');
  p0        = pl.find('P0');
  winname   = pl.find('WIN');
  freqs     = pl.find('FREQUENCIES');
  bindata   = pl.find('BIN DATA');
  polyft    = pl.find('FIT NOISE MODEL');
  Nexp      = size(acc_mfh,2);
  Nout      = size(acc_mfh,1);
  S         = matrix.initObjectWithSize(1,Nexp);
  
  if isempty(pl.find('INVERSE'))
    pl.pset('INVERSE', true);
  end

  % Handle the noise data: Cases are AO, MFH and SMODEL
  v = MCMC.handle_data_for_icsm(acc_mfh_n, p0, Nout, trim, fs, yun, pl.find('VERSION'));
  
  % Loop over experiments
  for kk = 1:Nexp
    
    % Eval time series, and trim the edges depending the LLH version
    vs = acc_mfh.index(1,kk).eval(p0);
    if isa(vs.data, 'tsdata')
      % Define plist
      spl = plist('offsets', trim./vs.fs);
      % Do the split
      vs  = split(vs,spl);
    elseif isa(vs.data, 'cdata') && any(strcmpi(pl.find('version'), {'ao', 'td ao'}))
      error('### The likelihood version is ''AO'' and in frequency domain, while the model produces cdata. A model that results to tsdata is necessary for FFT... ')
    elseif isa(vs.data, 'cdata')
      % Define plist
      spl = plist('offsets', trim./fs);
      % Define tsdata AO
      vs  = split(ao(plist('yvals', double(acc_mfh.index(1,kk).eval(p0)),'fs',fs,'xunits','s','yunits',yun,'type','tsdata')),spl);
    end
  
    % compute inverse cross-spectrum matrix
    scpl = plist('NOISE SCALE',      pl.find('NOISE SCALE'),...
                 'WIN',              winname,...
                 'NOUT',             Nout,...
                 'FREQS',            x(split(fft(vs), plist('frequencies', freqs))),...
                 'NAVS',             navs,...
                 'OLAP',             olap,...
                 'ORDER',            ordr,...
                 'BIN DATA',         bindata,...
                 'FIT NOISE MODEL',  polyft,...
                 'POLYNOMIAL ORDER', pl.find('POLYNOMIAL ORDER'),...
                 'INVERSE',          pl.find('INVERSE'),...
                 'ISDIAG',           pl.find('ISDIAG'),...
                 'PLOT FITS',        pl.find('DOPLOT'),...
                 'INTERP METHOD',    pl.find('INTERPOLATION METHOD'));
  
    S(kk) = MCMC.computeICSMatrix(v, scpl);
  end
  
end

%--------------------------------------------------------------------------
% EVALUATE THE MODEL / Check for errors
%--------------------------------------------------------------------------
function out = checkModel(model, p0, fs, yun)
  
  Nexp = size(model,2);
  Nout = size(model,1);
  out  = ao.initObjectWithSize(Nout, Nexp);
    
  fprintf('\n');
  try
    for kk=1:Nexp
      for ii = 1:Nout
         mname = model.index(ii,kk).name;
        fprintf('* Checking model [%s], index(%d,%d) at given data and parameters ... \n', mname, ii, kk);
        out(ii,kk) = model.index(ii,kk).eval(p0);
        % Check if it's tsdata
        if isa(out(ii,kk).data, 'cdata')
          if isempty(fs)
            error('Please specify the sample rate of the data when defining the loglikelihood.');
          end          
          out(ii,kk) = ao(plist('yvals',double(out(ii,kk)),'fs',fs,'xunits','s','yunits',yun,'type','tsdata','name',out.index(ii,kk).name));
        end
      end
    end
    fprintf('\n * Model tests successfully completed. \n');
  catch Me
    warning('### The model used cannot be calculated at the given input data and parameter values... Error: [%s]', Me.message)
  end
  
end

%--------------------------------------------------------------------------
% PLOT OF THE FFT OF THE SIGNALS / Check for errors
%--------------------------------------------------------------------------
function plotFFTsignals(acc_mfh, S, fft_signals, p0)

  Nout = size(S(1).objs,1);
  Nexp = size(fft_signals,2);
  try
    data = ao.initObjectWithSize(Nout, Nexp);
    for kk = 1:Nexp
      for ii = 1:Nout
        acc_fs        = fft_signals.index(ii,kk).eval(p0);
        % Get the name of the model
        nm            = acc_mfh.index(ii,kk).name;
        data(ii,kk)   = abs(ao(plist('yvals',  acc_fs.y,...
                                     'xvals',  S(kk).objs(1).x,...
                                     'xunits', 'Hz',...
                                     'type',   'fsdata',...
                                     'name',  ['FFT(', nm, sprintf(', exp. %d', kk), ')'])));
      end
      hfig = iplot(data(:,kk), plist('titles', {'The FFT of the experiment time series.'}));
      % Rename figure
      set(hfig, 'Name', 'FFT of the time series')
    end
  catch Me
    warning('LTPDA:mfh_model_loglikelihood', ...
      ['It seems that the cross-spectrum matrix of the noise and the FFT of '...
      'the signals do not have the same length. This will induce an error later '...
      'in the process. Please check again: %s'], Me.message)
  end
end
%--------------------------------------------------------------------------
% AUTHORS SHOULD NOT NEED TO EDIT BELOW HERE
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Get Version
%--------------------------------------------------------------------------
function v = getVersion
  
  v = '$Id$';
  
end

% END