% MFH_MODEL_DELAYED_DIFF_TS constructs delayed differentiated time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_DELAYED_DIFF_TS constructs delayed diff. time series.
%
% CALL:        a = mfh(plist('built-in', 'delayed_diff_ts'), pl);
%
% OUTPUTS:
%           mdl - an MFH object with the desired propertis.
%
% EXAMPLE: a =  mfh(plist('built-in', 'delayed_diff_ts'));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_delayed_diff_ts')">Model Information</a>
%
%
% REFERENCES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_delayed_diff_ts(varargin)
  
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
  desc = 'Constructs a @mfh object for a delayed differentiation of a time series. ';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The outputs can be MFH objects that compute the first or second '...
    'derivative of given time-series after delaying the input by the specified time.' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'First Derivative', @dt, ...
    'Second Derivative', @dtdt, ...
    'Delayed First Derivative', @deldt, ...
    'Delayed Second Derivative', @deldtdt, ...
    };
  
end

% dt
%
function varargout = dt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'DT'
        p = param({'FS',['The asmpling frequency of the time series. It can be '...
                         'a vector for un-even sampled time series taken from diff(ao.x).']},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);  
                       
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('dxdt'));
        pl.append(p);
        
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a first derivative';
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
  
  if isempty(fs)
    error('The key ''FS'' of the plist is necessary...')
  end
  
  % Derivative  
  dxdt = mfh(plist('name',         nm, ...
                   'func',         'ao.diff3p_core(y, dt)', ...
                   'inputs',       {'y'},...
                   'constants',    {'dt'}, ...
                   'constObjects', {1/fs}));
  
  varargout{1} = dxdt;
  
end

% deldtdt
%
function varargout = dtdt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'DT'
        p = param({'FS',['The sampling frequency of the time series. It can be '...
                         'a vector for un-even sampled time series taken from diff(ao.x).']},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('d2xdt2'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a second derivative.';
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
  
  if isempty(fs)
    error('The key ''FS'' of the plist is necessary...')
  end
  
  % Derivative
  dx2dt2 = mfh(plist('name',         nm, ...
                     'func',         'ao.diff3p_core(ao.diff3p_core(y, dt), dt)', ...
                     'inputs',       {'y'},...
                     'constants',    {'dt'}, ...
                     'constObjects', {1/fs}));
  
  varargout{1} = dx2dt2;
  
end


% deldt
%
function varargout = deldt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'FS'
        p = param({'FS','The sampling frequency of the time series.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p);  
                       
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('dTauD1'));
        pl.append(p);
        
        % delay type
        p = param({'DELAY TYPE', 'The type of the delay to use for the ''delayX'' and ''delFiltX'' functions.'}, ...
          {2, {'fftfilter','timedomain','fdfilter'}, paramValue.SINGLE});
        pl.append(p);
        
        % window
        p = param({'window', 'The window to use for the ''fdfilter'' delay mode.'}, {2, {'blackman', 'blackman3', 'lagrange'}, paramValue.SINGLE});
        pl.append(p);
        
        % Taps
        p = param({'taps', 'The number of taps used in the ''fdfilter'' delay mode.'}, {1, {51}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a first derivative';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl      = copy(varargin{1}, 1);
  nm      = pl.find('NAME');
  nfft    = pl.find('NFFT');
  fs      = pl.find('FS');
  deltype = pl.find('DELAY TYPE');
  
  if isempty(fs)
    error('The key ''FS'' of the plist is necessary...')
  end
  
  % delay type
  switch deltype
    case 'timedomain'
      % delay expression for the fractional version
      delayExpr = 'ao.delay_fractional_core(y, tau, dt)';
      
      % Derivative
      dxdt = mfh(plist('name',         nm, ...
                       'func',         sprintf('ao.diff3p_core(%s,dt)', delayExpr), ...
                       'inputs',       {'y', 'tau'},...
                       'constants',    {'dt'}, ...
                       'constObjects', {1./fs}));
    case 'fftfilter'
      % delay expression for the fftfilter version
      delayExpr = 'ao.split_samples_core(ao.ifft_1sided_odd_core(pz.resp_add_delay_core(ao.fft_1sided_core(ao.zeropad_post_core(y, nfft-1)), fr, tau), type), [1 nfft])';
       
      % NFFT is neede in thi cases
      if isempty(nfft)
        error('The key ''NFFT'' of the plist is necessary...')
      end
  
      fr = utils.math.getfftfreq(2*nfft - 1, fs, 'one');
      
      % Derivative
      dxdt = mfh(plist('name',         nm, ...
                       'func',         sprintf('ao.diff3p_core(%s,dt)', delayExpr), ...
                       'inputs',       {'y', 'tau'},...
                       'constants',    {'dt', 'nfft', 'fr', 'type'}, ...
                       'constObjects', {1/fs, nfft, fr, 'symmetric'}));
                     
      case 'fdfilter'
      % delay expression for the fftfilter version
      delayExpr = 'utils.math.fdfilt_delay_core(x, tau*fs, taps, wind)';
                     
      wind = lower(pl.find_core('window'));
      taps = lower(pl.find_core('taps'));
    
      % Delay function
      dxdt = mfh(plist('name',           nm, ...
                         'func',         sprintf('ao.diff3p_core(%s,dt)', delayExpr), ...
                         'inputs',       {'x', 'tau'},...
                         'constants',    {'fs', 'taps', 'wind','dt'}, ...
                         'constObjects', {fs, taps, wind, 1/fs}));               
  end
  
  varargout{1} = dxdt;
  
end

% deldtdt
%
function varargout = deldtdt(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'FS'
        p = param({'FS','The sampling frequency of the time series.'},  paramValue.DOUBLE_VALUE(1));
        pl.append(p); 
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('dTauD2'));
        pl.append(p);
        
        % delay type
        p = param({'DELAY TYPE', 'The type of the delay to use for the ''delayX'' and ''delFiltX'' functions.'}, ...
          {2, {'fftfilter','timedomain','fdfilter'}, paramValue.SINGLE});
        pl.append(p);
        
        % window
        p = param({'window', 'The window to use for the ''fdfilter'' delay mode.'}, {2, {'blackman', 'blackman3', 'lagrange'}, paramValue.SINGLE});
        pl.append(p);
        
        % Taps
        p = param({'taps', 'The number of taps used in the ''fdfilter'' delay mode.'}, {1, {51}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version makes a second derivative.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl      = copy(varargin{1}, 1);
  nm      = pl.find('NAME');
  nfft    = pl.find('NFFT');
  fs      = pl.find('FS');
  deltype = pl.find('DELAY TYPE');
  
  if isempty(fs)
    error('The key ''FS'' of the plist is necessary...')
  end

  % delay type
  switch deltype
    case 'timedomain'
      % delay expression for the fractional version
      delayExpr = 'ao.delay_fractional_core(y, tau, dt)';
      
      % Derivative
      dx2dt2 = mfh(plist('name',         nm, ...
                         'func',         sprintf('ao.diff3p_core(ao.diff3p_core(%s,dt),dt)', delayExpr), ...
                         'inputs',       {'y', 'tau'},...
                         'constants',    {'dt'}, ...
                         'constObjects', {1/fs}));
                       
    case 'fftfilter'
      % delay expression for the fftfilter version
      delayExpr = 'ao.split_samples_core(ao.ifft_1sided_odd_core(pz.resp_add_delay_core(ao.fft_1sided_core(ao.zeropad_post_core(y, nfft-1)), fr, tau), type), [1 nfft])';
  
      if isempty(nfft)
        error('The key ''NFFT'' of the plist is necessary...')
      end
      
      fr = utils.math.getfftfreq(2*nfft - 1, fs, 'one');
      
      % Derivative
      dx2dt2 = mfh(plist('name',         nm, ...
                         'func',         sprintf('ao.diff3p_core(ao.diff3p_core(%s,dt),dt)', delayExpr), ...
                         'inputs',       {'y', 'tau'},...
                         'constants',    {'dt', 'nfft', 'fr', 'type'}, ...
                         'constObjects', {1/fs, nfft, fr, 'symmetric'}));
                       
    case 'fdfilter'
      
     % delay expression for the fftfilter version
      delayExpr = 'utils.math.fdfilt_delay_core(x, tau*fs, taps, wind)';
                     
      wind = lower(pl.find_core('window'));
      taps = lower(pl.find_core('taps'));
    
      % Delay function
      dx2dt2 = mfh(plist('name',           nm, ...
                         'func',         sprintf('ao.diff3p_core(ao.diff3p_core(%s,dt), dt)', delayExpr), ...
                         'inputs',       {'x', 'tau'},...
                         'constants',    {'fs', 'taps', 'wind','dt'}, ...
                         'constObjects', {fs, taps, wind, 1/fs}));  
                   
  end
  
  varargout{1} = dx2dt2;
  
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

