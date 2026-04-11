% mfh_model_delay_ts constructs differentiated time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_DELAY_TS constructs MFH for delaying time series.
%
% CALL:        a = mfh(plist('built-in', 'delay_ts'), pl);
%
% OUTPUTS:
%           mdl - an MFH object with the desired propertis.
%
% EXAMPLE: a =  mfh(plist('built-in', 'delay_ts'));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_delay_ts')">Model Information</a>
%
%
% REFERENCES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_delay_ts(varargin)
  
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
  desc = 'Constructs a @mfh object for delaying a time series. ';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The outputs can be MFH objects that compute delayed time-series '...
    'using a fractional delay (del e [0,1]) or by fft filtering.' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'timedomain', @timedomain, ...
    'fftfilter',  @fftfilt, ...
    'fdfilter',   @fdfilter,...
    };
  
end


% fractional
%
function varargout = timedomain(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'DT'
        p = param({'FS','The sampling frequency of the time series.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('delayX'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses timedomain delay filtering';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl = copy(varargin{1}, 1);
  fs = pl.find('FS');
  nm = pl.find('NAME');
  
  if isempty(fs)
    error('The key ''FS'' of the plist is necessary...')
  end
  
  % Delay function
  delayX = mfh(plist('name',         nm, ...
                     'func',         'ao.delay_fractional_core(x, tau, dt)', ...
                     'inputs',       {'x', 'tau'},...
                     'constants',    {'dt'}, ...
                     'constObjects', {1/fs}));
  
  varargout{1} = delayX;
  
end

% fftfilt
%
function varargout = fftfilt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('delayX'));
        pl.append(p);
        
        % parameter 'DT'
        p = param({'FS','Sampling frequency of the time series.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses fft filtering to implement the delay.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl   = copy(varargin{1}, 1);
  nfft = pl.find('NFFT');
  nm   = pl.find('NAME');
  fs   = pl.find('FS');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  fr = utils.math.getfftfreq(2*nfft - 1, fs, 'one');
  
  % Delay function
  delayX = mfh(plist('name',         nm, ...
                     'func',         'ao.split_samples_core(ao.ifft_1sided_odd_core(pz.resp_add_delay_core(ao.fft_1sided_core(ao.zeropad_post_core(x, nfft-1)), fr, tau), type), [1 nfft])', ...
                     'inputs',       {'x', 'tau'},...
                     'constants',    {'nfft', 'fr', 'type'}, ...
                     'constObjects', {nfft, fr, 'symmetric'}));
  
  varargout{1} = delayX;
  
end

% fdfilter
%
function varargout = fdfilter(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('delayX'));
        pl.append(p);
        
        % parameter 'DT'
        p = param({'FS','Sampling frequency of the time series.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % window
        p = param({'window', 'The window to use for the ''fdfilter'' delay mode.'}, {2, {'blackman', 'blackman3', 'lagrange'}, paramValue.SINGLE});
        pl.append(p);
        
        % Taps
        p = param({'taps', 'The number of taps used in the ''fdfilter'' delay mode.'}, {1, {51}, paramValue.OPTIONAL});
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version uses fft filtering to implement the delay.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl   = copy(varargin{1}, 1);
  nm   = pl.find('NAME');
  fs   = pl.find('FS');
  
  wind = lower(pl.find_core('window'));
  taps = lower(pl.find_core('taps'));
    
  % Delay function
  delayX = mfh(plist('name',         nm, ...
                     'func',         'utils.math.fdfilt_delay_core(x, tau*fs, taps, wind)', ...
                     'inputs',       {'x', 'tau'},...
                     'constants',    {'fs', 'taps', 'wind'}, ...
                     'constObjects', {fs, taps, wind}));
  
  varargout{1} = delayX;
  
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

