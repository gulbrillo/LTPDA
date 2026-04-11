% mfh_model_fft_signals constructs the FFT of time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_FFT_SIGNALS constructs MFH for applying FFT to time
%                                    series. Used mostly for the
%                                    construction of the log-likelihood.
%
% CAUTION: The number of experiments are taken from the number of columns of the   
%          given MFH time-series function. The number of channels of the
%          investigation are quivalent to the number of rows of the MFH. 
% 
% For example:
% 
%               data_channel1 = [data_channel1_exp1, data_channel1_exp2]; 
%               data_channel2 = [data_channel2_exp1, data_channel2_exp2];
%
% CALL:        a = mfh(plist('built-in', 'fft_signals'), pl);
%
% OUTPUTS:
%           mdl - an MFH object with the desired propertis.
%
% EXAMPLE: a =  mfh(plist('built-in', 'fft_signals'));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_fft_signals')">Model Information</a>
%
% NK 2013
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_fft_signals(varargin)
  
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
  desc = 'Constructs a @mfh object for applying FFT to given time series. ';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'Constructs a @mfh object for applying FFT to given time series. ' ...
    'The MFH time-series model must have been created with the appropriate '...
    'plist keys. The ''CORE'' version of the ''fft_signals'' model must be used ' ...
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
    'core', @core, ...
    'ao',   @AO, ...
    };
  
end


% CORE
%
function varargout = core(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'SAMPLES TO SPLIT'
        p = param({'frequencies','The frequency range.'},  paramValue.DOUBLE_VALUE([]));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handles.'},  paramValue.EMPTY_CELL);
        pl.append(p);
        
        % parameter 'TS FH'
        p = param({'TS FH','The time series function handles to perform the FFT. Must be in an array.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'P0'
        p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'TRIM'
        p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([100 -100]));
        pl.append(p);
        
        % parameter 'WIN'
        p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
        pl.append(p);
        
        % parameter 'FS'
        p = param({'FS','For the cae of ''CORE'', the sampling frequency of the time series is needed.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'ETAS'
        p = param({'BIN GROUPS',['A numerical vector that denotes to the start and end frequency value that corresponds to the given '...
                           'frequency block amplitude. For more information, please type >> doc mfh_model_loglikelihood.']},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'S'
        p = param({'S','The inverse cross-spectrum matrix. Used fro the case of the student-t likelihood. '},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'error ratio'
        p = param({'ERROR RATIO','The percentage of knowldge level of each frequency bin.  Used fro the case of the student-t likelihood'},  paramValue.DOUBLE_VALUE(0.5));
        pl.append(p);
        
        % parameter 'NU'
        p = param({'NU',['The ''degrees of freedom'' parameter for the student-t distribution, as proposed in PRD 84, 122004 (2011). ', ...
                         'There are three posibilities to ad th nu coefficient. The ''COMMON'' choise, follows the simplified logic ', ...
                         'that the noise frequency bins follow the same distribution. The second ''BY BIN GROUPS'' considers common ',...
                         'value for the coefficient for neighboring frequency bins, defined with the key ''BIN GROUPS''. The last choice ',...
                         'considers a dofferent degree of freedom for each frequency bin.']},  ...
                  {1, {'common','by bins groups','by bins'}, paramValue.SINGLE});
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses fractional delay filtering';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl          = copy(varargin{1}, 1);
  freqs       = pl.find('FREQUENCIES');
  nm          = pl.find('NAME');
  acc_mfh     = pl.find('TS FH');
  p0          = pl.find('P0');
  trim        = pl.find('TRIM');
  winname     = pl.find('WIN');
  fs          = pl.find('FS');
  
  if isempty(acc_mfh) || isempty(p0) || isempty(freqs)
    error('Please input the time-series model in MFH format and a numerical parameter vector. Also the frequency range.')
  end
  
  % Get # of experiments
  Nexp        = size(acc_mfh,2);
  Nout        = size(acc_mfh,1);
  fft_signals = mfh.initObjectWithSize(Nout,Nexp);
  eta_vectors = cell(1, Nexp);
  nu_vectors  = cell(1, Nexp);
  s           = matrix();
  Smat        = pl.find('S');
  
  % Check if isempty
  if isempty(Smat)
    Smat = matrix.initObjectWithSize(1, Nexp);
  end
  
  % Put name into cell array
  if ~iscell(nm) && ischar(nm);
    [names{1:Nout,1:Nexp}] = deal(nm);
  else
    names = nm;
  end
    
  % Loop over experiments
  for kk=1:Nexp
    
    % Get length
    v        = acc_mfh.index(1,kk).eval(p0);
    nsamples = v.len;
    
    % Get the window
    w = specwin(winname, nsamples - sum(abs(trim))).win';
    
    % Normalisation factor
    K = w'*w;
    w = w./sqrt(K);
    
    % define the frequency range
    v_s   = split(ao(plist('type', 'tsdata', 'yvals', v.y, 'xunits', 's', 'fs', fs)), plist('offsets', trim./fs));
    v_f   = fft(v_s);
    f_ini = v_f.x;
    v_f   = split(v_f, plist('frequencies', freqs));
    f     = v_f.x;
    
    % Scale of FFT to PSD
    scale = sqrt(4/fs);
    
    % Get samples to split in frequencies
    spltsmpls = samplesToSplit(f_ini, f);
    
    % Get noise amplitude vectors (all ones)
    eta_vectors{kk} = getEtaVectors(pl.find('BIN GROUPS'), f);
    
    % Get noise 'nu' DOFs. For the case of the student-t likelihood
    [nu_vectors{kk}, s(kk)] = getNuVectors(pl.find('NU'), pl.find('BIN GROUPS'), f, Smat(kk), pl.find('ERROR RATIO'));
    
    for ii = 1:Nout
      mm = acc_mfh.index(ii,kk);
      expr = sprintf('scale.*ao.split_samples_core(ao.fft_1sided_core(ao.split_samples_core(%s(p), [%d+1 %d+%d]).*w),[%d, %d])', ...
        mm.name, trim(1), nsamples, trim(2), spltsmpls(1), spltsmpls(2));
      
      % Define minFuncks!
      fft_signals(ii,kk) = mfh(plist(...
        'name',             names{ii,kk},...
        'func',             expr,...
        'inputs',           'p', ...
        'constants',        {'scale','trim', 'Ns', 'w'}, ...
        'constant objects', {scale, trim, nsamples, w}, ...
        'numeric',          true, ...
        'subfuncs',         mm));
      
    end
  end
  
  % set the procinfo plist
  fft_signals.setProcinfo(plist('eta vectors', eta_vectors, 'nu vectors', nu_vectors, 's', s, 'freqs', f));
  
  % set the output
  varargout{1} = fft_signals;
  
end

% AO
%
function varargout = AO(varargin)
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'SAMPLES TO SPLIT'
        p = param({'frequencies','The frequency range.'},  paramValue.DOUBLE_VALUE([]));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handles.'},  paramValue.EMPTY_CELL);
        pl.append(p);
        
        % parameter 'TS FH'
        p = param({'TS FH','The time series function handles to perform the FFT. Must be in an array.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'P0'
        p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'TRIM'
        p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([100 -100]));
        pl.append(p);
        
        % parameter 'TRIM'
        p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses fractional delay filtering';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl          = copy(varargin{1}, 1);
  freqs       = pl.find('FREQUENCIES');
  nm          = pl.find('NAME');
  acc_mfh     = pl.find('TS FH');
  p0          = pl.find('P0');
  trim        = pl.find('TRIM');
  winname     = pl.find('WIN');
  
  % Get # of experiments
  Nexp = size(acc_mfh,2);
  Nout = size(acc_mfh,1);
  fft_signals = mfh.initObjectWithSize(Nout,Nexp);
  
  % Put name into cell array
  if ~iscell(nm) && ischar(nm);
    [names{1:Nout,1:Nexp}] = deal(nm);
  else
    names = nm;
  end
  
  if isempty(acc_mfh) || isempty(p0) || isempty(freqs)
    error('Please input the time-series model in MFH format and a numerical parameter vector. Also the frequency range.')
  end
      
  % Loop over experiments
  for kk=1:Nexp
    
    % Get length
    v        = acc_mfh.index(1,kk).eval(p0);
    nsamples = v.len - sum(abs(trim));    

    for ii = 1:Nout
      expr = sprintf('scale.*double(split(fft_core(win.*split(%s(p), tspl), ''one''), spl))', acc_mfh(ii).name);

      % Get numerical values of window (a little faster)
      fs    = acc_mfh.index(ii).constObjects{1}.fs;
      w     = ao(plist('win', winname, 'length', nsamples));
      K     = w*w.'; 
      w     = (w./sqrt(K)).'; % Normalise
      scale = sqrt(4/fs); % Scale of FFT to PSD
      spl   = plist('frequencies', freqs);
      tspl  = plist('offsets', trim./fs(1));
      mm    = acc_mfh.index(ii,kk);

      fft_signals(ii,kk) = mfh(plist(...
              'func',         expr, ...
              'name',         names{ii,kk}, ...
              'inputs',       'p', ...
              'subfuncs',     mm, ...
              'constants',    {'scale', 'spl', 'win', 'tspl'},...
              'numeric',      false, ...
              'constObjects', {scale, spl, w, tspl}));

    end
  
  end
  
  varargout{1} = fft_signals;
  
end

%
% Define the samples to split in frequency
%
function samples = samplesToSplit(f_ini, f)
  
  ism        = ismember(f_ini, f);
  samples(1) = find(ism == 1, 1, 'first');
  samples(2) = numel(ism) - find(flipud(ism) == 1, 1, 'first') + 1;
  
end

%
% Define the eta vectors  
%
function eta_vectors = getEtaVectors(etaF, f)
  
  % check frequency bins
  if  ~isempty(etaF) && (max(etaF) > f(end) || min(etaF) < f(1))
    error('### Eta vectors not defined correctly. Please check again...')
  end

  if ~isempty(etaF)
    fr          = zeros(size(etaF));
    eta_vectors = cell(1, numel(etaF)+1);
    index_0     = 0;
    for jj = 1:numel(etaF)
      [~,bin] = histc(etaF(jj),f);
      index   = bin + 1;      
      if abs(etaF(jj)-f(bin))<abs(etaF(jj)-f(bin+1))
        fr(jj) = f(bin);
        index  = bin;
      else
        fr(jj) = f(index);
      end
      eta_vectors{jj} = ones(size(f(index_0+1:index)));
      index_0         = index;
    end
    eta_vectors{jj+1} = ones(size(f(index_0+1:numel(f))));
  else
    eta_vectors{1} = ones(size(f));
  end
  
end

%
% Define the nu vectors  
%
function [nu_vectors, s] = getNuVectors(nu, bingroups, f, s, err)

  if strcmpi(nu, 'by bin groups') && numel(nu)>1 && ~isempty(bingroups) 
    fr          = zeros(size(bingroups));
    nu_vectors = cell(1, numel(bingroups)+1);
    index_0     = 0;
    for jj = 1:numel(bingroups)
      [~,bin] = histc(bingroups(jj),f);
      index   = bin + 1;      
      if abs(bingroups(jj)-f(bin))<abs(bingroups(jj)-f(bin+1))
        fr(jj) = f(bin);
        index  = bin;
      else
        fr(jj) = f(index);
      end
      nu_vectors{jj} = ones(size(f(index_0+1:index)));
      index_0        = index;
    end
    nu_vectors{jj+1} = ones(size(f(index_0+1:numel(f))));
    s = [];
    
  elseif strcmpi(nu, 'common')
    
    nu_vectors{1} = ones(size(f));
    s = [];
    
  elseif strcmpi(nu, 'by bins')
    
    nu_vectors{1} = 4 + 2.*err;
    s             = (nu_vectors{1}./(nu_vectors{1} - 2)).*s;
    
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