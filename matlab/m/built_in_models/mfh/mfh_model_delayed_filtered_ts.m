% mfh_model_delayed_filtered_ts constructs filtered time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH_MODEL_DELAYED_FILTERED_TS constructs filtered
%                                            time series.
%
% CALL:        a = mfh(plist('built-in', 'delayed_filtered_ts'), pl);
%
% OUTPUTS:
%           mdl - an MFH object with the desired filters.
%
% EXAMPLE: a =  mfh(plist('built-in','delayed_filtered_ts','nsecs',10,'sigma',1,'fs',100,'toff',0));
%
% INFO:
%   <a href="matlab:utils.models.displayModelOverview('mfh_model_delayed_filtered_ts')">Model Information</a>
%
%
% REFERENCES:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfh_model_delayed_filtered_ts(varargin)
  
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
  desc = 'Constructs a @mfh object to filter time-series.';
end

function doc = getModelDocumentation
  doc = sprintf([...
    'The filter is a single real pole pzmodel. The inputs of the function are: '...
          '<ul>',...
          '<li>the time series',...
          '<li>the gain of the filter',...
          '<li>the pole',...
          '<li>and a given delay in seconds (Use version ''Filtered delayed TS'' or ''Filtered fftfilt delay'').',...
          '</ul>' ...
    ]);
end

function package = getPackageName
  package = 'ltpda';
end

% default version is always the first one
function vt = versionTable()
  
  vt = {...
    'Filtered TS', @filtTS, ...
    'Filtered TS no gain', @filtTSnoG, ...
    'Filtered delayed TS', @filtDelTS,...
    'Filtered fftfilt delay', @fftfiltDelTS, ...
    'Filtered fdfilter delay' @fdfiltfiltDelTS ...
    };
  
end


% filtTS
%
function varargout = filtTS(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('pz'));
        pl.append(p);
        
        % parameter 'DT'
        p = param({'DT','1/FS or DT of the time series.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version just applies the gain/pole filter.';
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
  dt   = pl.find('DT');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
  
  fr = utils.math.getfftfreq(2*nfft - 1, 1/dt, 'one');
  
  F = mfh(plist('name',         nm, ...
                'func',         'ao.split_samples_core(ao.ifft_1sided_odd_core(G.*pz.resp_pz_noQ_core(fr, pole).''.*ao.fft_1sided_core(ao.zeropad_post_core(x, nfft-1)), type), [1 nfft])', ...
                'inputs',       {'x', 'G', 'pole'}, ...
                'constants',    {'fr', 'nfft', 'type'}, ...
                'constObjects', {fr, nfft, 'symmetric'}));
  
  varargout{1} = F;
  
end

% filtTS
%
function varargout = filtTSnoG(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('pz'));
        pl.append(p);
        
        % parameter 'DT'
        p = param({'DT','1/FS or DT of the time series.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version just applies the gain/pole filter.';
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
  dt   = pl.find('DT');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
  
  fr = utils.math.getfftfreq(2*nfft - 1, 1/dt, 'one');
  
  F = mfh(plist('name',         nm, ...
                'func',         'ao.split_samples_core(ao.ifft_1sided_odd_core(pz.resp_pz_noQ_core(fr, pole).''.*ao.fft_1sided_core(ao.zeropad_post_core(x, nfft-1)), type), [1 nfft])', ...
                'inputs',       {'x', 'pole'}, ...
                'constants',    {'fr', 'nfft', 'type'}, ...
                'constObjects', {fr, nfft, 'symmetric'}));
  
  varargout{1} = F;
  
end

% filtDelTS
%
function varargout = filtDelTS(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'DT'
        p = param({'DT','1/FS or DT of the time series.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('pzDel'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version applies the gain/pole filter and an additional (fractional) delay.';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl   = copy(varargin{1}, 1);
  nfft = pl.find('NFFT');
  dt   = pl.find('DT');
  nm   = pl.find('NAME');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
  
  fr = utils.math.getfftfreq(2*nfft - 1, 1/dt, 'one');
  
  F = mfh(plist('name',         nm, ...
                'func',         'ao.split_samples_core(ao.ifft_1sided_odd_core(G.*pz.resp_pz_noQ_core(fr, pole).''.*ao.fft_1sided_core(ao.zeropad_post_core(ao.delay_fractional_core(x, tau, dt), nfft-1)), type), [1 nfft])', ...
                'inputs',       {'x', 'G', 'pole', 'tau'}, ...
                'constants',    {'fr', 'nfft', 'dt', 'type'}, ...
                'constObjects', {fr, nfft, dt, 'symmetric'}));
  
  varargout{1} = F;
  
end

% fftfiltDelTS
%
function varargout = fftfiltDelTS(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'DT'
        p = param({'DT','1/FS or DT of the time series.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('pzDel'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version applies the gain/pole filter and an additional (fftfilter) delay..';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl   = copy(varargin{1}, 1);
  nfft = pl.find('NFFT');
  dt   = pl.find('DT');
  nm   = pl.find('NAME');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
    
  % build delay model
  delayExpr = 'ao.split_samples_core(ao.ifft_1sided_odd_core(pz.resp_add_delay_core(ao.fft_1sided_core(ao.zeropad_post_core(x, nfft-1)), fr, tau), type), [1 nfft])';

  fr = utils.math.getfftfreq(2*nfft - 1, 1/dt, 'one');
  
  filtExpr = sprintf('ao.split_samples_core(ao.ifft_1sided_odd_core(G.*pz.resp_pz_noQ_core(fr, pole).''.*ao.fft_1sided_core(ao.zeropad_post_core(%s, nfft-1)), type), [1 nfft])', delayExpr);
  
  F = mfh(plist('name',         nm, ...
                'func',         filtExpr, ...
                'inputs',       {'x', 'G', 'pole', 'tau'}, ...
                'constants',    {'fr', 'nfft', 'dt', 'type'}, ...
                'constObjects', {fr, nfft, dt, 'symmetric'}));
  
  varargout{1} = F;
  
end

% fftfiltDelTS
%
function varargout = fdfiltfiltDelTS(varargin)
  
  if nargin == 1 && ischar(varargin{1})
    switch varargin{1}
      case 'plist'
        
        % The plist for this version of this model
        pl = plist();
        
        % parameter 'NFFT'
        p = param({'NFFT','The number of samples of the given time series. Used for FFT filtering.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % window
        p = param({'window', 'The window to use for the ''fdfilter'' delay mode.'}, {2, {'blackman', 'blackman3', 'lagrange'}, paramValue.SINGLE});
        pl.append(p);
        
        % Taps
        p = param({'taps', 'The number of taps used in the ''fdfilter'' delay mode.'}, {1, {51}, paramValue.OPTIONAL});
        pl.append(p);
        
        % parameter 'DT'
        p = param({'DT','1/FS or DT of the time series.'},  paramValue.EMPTY_DOUBLE);
        pl.append(p);
        
        % parameter 'NAME'
        p = param({'NAME','The name of the function handle.'},  paramValue.STRING_VALUE('pzDel'));
        pl.append(p);
        
        varargout{1} = pl;
        
      case 'description'
        varargout{1} = 'This version applies the gain/pole filter and an additional (fftfilter) delay..';
      case 'info'
        varargout{1} = [];
      otherwise
        error('unknown inputs');
    end
    return;
  end
  
  pl   = copy(varargin{1}, 1);
  nfft = pl.find('NFFT');
  dt   = pl.find('DT');
  nm   = pl.find('NAME');
  
  if isempty(nfft)
    error('The key ''NFFT'' of the plist is necessary...')
  end
  
  if isempty(dt)
    error('The key ''DT'' of the plist is necessary...')
  end
    
  
  wind = lower(pl.find_core('window'));
  taps = lower(pl.find_core('taps'));
  fr   = utils.math.getfftfreq(2*nfft - 1, 1/dt, 'one');

  % Delay expression
  delayExpr = 'utils.math.fdfilt_delay_core(x, tau*(1/dt), taps, wind)';
  
  % filter expression
  filtExpr = sprintf('ao.split_samples_core(ao.ifft_1sided_odd_core(G.*pz.resp_pz_noQ_core(fr, pole).''.*ao.fft_1sided_core(ao.zeropad_post_core(%s, nfft-1)), type), [1 nfft])', delayExpr);
  
  F = mfh(plist('name',         nm, ...
                'func',         filtExpr, ...
                'inputs',       {'x', 'G', 'pole', 'tau'}, ...
                'constants',    {'fr', 'nfft', 'dt', 'type', 'taps', 'wind'}, ...
                'constObjects', {fr, nfft, dt, 'symmetric', taps, wind}));
  
  varargout{1} = F;
  
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

