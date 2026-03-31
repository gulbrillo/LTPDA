% FROMWAVEFORM Construct an ao from a waveform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromWaveform
%
% DESCRIPTION: Construct an ao from a waveform
%
% CALL:        a = fromWaveform(pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromWaveform(a, pli, callerIsMethod)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Waveform');
  
  % Apply default values
  pl = applyDefaults(ii.plists, pli);
  
  nsecs   = find_core(pl, 'nsecs');
  fs      = find_core(pl, 'fs');
  t0      = find_core(pl, 't0');
  offset  = find_core(pl, 'offset');
  
  waveform = find_core(pl, 'waveform');
  if numel(nsecs) == 1
    if isempty(nsecs) || nsecs == 0
      error('### Please provide ''Nsecs'' for waveform constructor.');
    end
  end
  if  isempty(fs) || fs == 0
    error('### Please provide ''fs'' for waveform constructor.');
  end
  
  % Remove the 'RAND_STREAM' if the wave form is not 'noise'.
  % That is necessary for the rebuild part. Only for 'noise' make it sense
  % to set a new seed.
  if ~strcmpi(waveform, 'noise')
    pl.remove('RAND_STREAM');
  end
  
  % Override defaults
  if isempty(t0)
    t0 = time(0);
  elseif ischar(t0) || isnumeric(t0)
    t0 = time(t0);
  end
  if isempty(find_core(pl, 'name'))
    pl.pset('Name', waveform);
  end
  
  
  switch lower(waveform)
    %------------ Sine Wave
    case {'sine wave', 'sinewave', 'sine-wave', 'sine'}
      ampl = find_core(pl, 'A');
      freq = find_core(pl, 'f');
      phi  = find_core(pl, 'phi');
      Toff = find_core(pl, 'Toff');
      gaps = find_core(pl, 'gaps');
      
      % If Toff is a time-string or a time object then convert this time
      % into a number of seconds depending to T0
      if ischar(Toff) || iscell(Toff) || isa(Toff, 'plist')
        
        % If the t0 is the default value then set it to the first value of Toff
        if strcmpi(find_core(pl, 't0'), '1970-01-01 00:00:00.000')
          t0 = time(Toff(1));
        end
        
        newToff = [];
        if ischar(Toff)
          newToff = (time(Toff).utc_epoch_milli - t0.utc_epoch_milli) /1e3;
        else
          Toff = time(Toff);
          for zz = 1:numel(Toff)
            newToff = [newToff (Toff(zz).utc_epoch_milli - t0.utc_epoch_milli)/1e3];
          end
        end
        
        Toff = newToff;
      end
      
      % The user specified gaps instead of offsets.
      % (The gap is before the signal starts)
      if isempty(pli.find_core('Toff')) && ~isempty(gaps)
        Toff(1) = gaps(1);
        for ww = 2:numel(nsecs)
          Toff(ww) = sum(gaps(1:ww)) + sum(nsecs(1:ww-1));
        end
      end
      
      % If the number of  Amplitude, frequency and phase are not the same
      % then duplicate the last specified value.
      max_waves = max([numel(ampl), numel(freq), numel(phi), numel(nsecs), numel(Toff)]);
      
      ampl  = [ampl, repmat(ampl(end),   1, max_waves - numel(ampl))];
      freq  = [freq, repmat(freq(end),   1, max_waves - numel(freq))];
      phi   = [phi,  repmat(phi(end),    1, max_waves - numel(phi))];
      nsecs = [nsecs, repmat(nsecs(end), 1, max_waves - numel(nsecs))];
      Toff  = [Toff, repmat(Toff(end),   1, max_waves - numel(Toff))];
      
      %%%%%%%%%%%%%%%%%%%%   add different sine waves with time offset  %%%%%%%%%%%%%%%%%%%%
      
      maxValues = 0;
      % Predefine the total result with zeros
      for kk = 1:numel(Toff)
        values = (Toff(kk) + nsecs(kk)) * fs;
        if maxValues < values
          maxValues = values;
        end
      end
      total = zeros(maxValues, 1);
      
      % Over all sine waves
      for kk = 1:numel(Toff)
        
        % Compute the y-values of each sine wave
        t = tsdata.createTimeVector(fs, nsecs(kk));
        y = ampl(kk) * sin(2*pi*freq(kk)*t + phi(kk));
        
        % Add the computed values to the total result
        begT = floor(Toff(kk)*fs);
        endT = begT + nsecs(kk)*fs;
        idx  = begT+1:endT;
        
        total(idx) = total(idx) + y;
        
      end
      
      if isempty(total)
        error('### You have defined a sine-wave with the length zero.');
      end
      
      ts = tsdata(total + offset, fs);
      ts.setXunits(find_core(pl, 'xunits'));
      ts.setYunits(find_core(pl, 'yunits'));
      ts.setT0(t0);
      
      % Handle toffset
      if ~isempty(pl.find_core('toffset'))
        ts.setToffset(1000*pl.find_core('toffset'));
      end
      
      % Make an analysis object
      a.data = ts;
      % Add history
      a.addHistory(ii, pl, [], []);
      
      % Set some procedure information
      a.procinfo = plist('start times', time(t0.utc_epoch_milli/1e3 + Toff));
      
      % Set the object properties from the plist
      a.setObjectProperties(pl, {'fs', 't0', 'offset', 'xunits', 'yunits'});
      
      % This is a special case where we don't evaluate a string function
      % but build the values according to the recipe. As such we have
      % already handled the setting of properties and history and we can
      % return here.
      return
      
    case 'noise'
      ntype = find_core(pl, 'type');
      pl.getSetRandState();
      
      if isempty(ntype)
        ntype = 'Normal';
      end
      sigma = find_core(pl, 'sigma');
      if isempty(sigma)
        sigma = 1;
      end
      
      switch lower(ntype)
        case 'normal'
          tsfcn = sprintf('%g.*randn(size(t))', sigma);
          
        case 'uniform'
          tsfcn = sprintf('%g.*rand(size(t))', sigma);
          
      end
      %------------ Chirp
    case 'chirp'
      f0  = find_core(pl, 'f0');
      fe  = find_core(pl, 'f1');
      te  = find_core(pl, 't1');
      if isempty(f0)
        f0 = 0;
      end
      if isempty(fe)
        fe = fs/2;
      end
      if isempty(te)
        te = nsecs;
      end
      tsfcn = sprintf('chirp(t,%g,%g,%g)', f0, fe, te);
      %------------ Gaussian pulse
    case {'gaussian pulse', 'gaussian-pulse'}
      fc  = find_core(pl, 'f0');
      bw  = find_core(pl, 'bw');
      if isempty(fc)
        fc = 1;
      end
      if isempty(bw)
        bw = fs/2;
      end
      tsfcn = sprintf('gauspuls(t,%g,%g)', fc, bw);
    case {'square wave', 'squarewave', 'square-wave', 'square'}
      freq = find_core(pl, 'f');
      duty = find_core(pl, 'duty');
      if isempty(freq)
        freq = 1;
      end
      if isempty(duty)
        duty = 50;
      end
      tsfcn = sprintf('square(2*pi*%g*t,%g)', freq, duty);
    case {'saw tooth', 'sawtooth', 'saw-tooth', 'saw'}
      freq  = find_core(pl, 'f');
      width = find_core(pl, 'width');
      if isempty(freq)
        freq = 1;
      end
      if isempty(width)
        width = 0.5;
      end
      tsfcn = sprintf('sawtooth(2*pi*%g*t,%g)', freq, width);
    otherwise
      error('### Unknown waveform type [%s]', waveform);
  end
  
  % construct tsdata: this is needed so that the tsfcn can be evaluated
  t = tsdata.createTimeVector(fs, nsecs);
  
  % make y data
  y = eval([tsfcn ';']);
  
  % add the offset
  y = y + offset;
  
  ts = tsdata(y, fs);
  ts.setT0(t0);
  ts.setXunits(find_core(pl, 'xunits'));
  ts.setYunits(find_core(pl, 'yunits'));
  
  % Handle toffset
  if ~isempty(pl.find_core('toffset'))
    ts.setToffset(1000*pl.find_core('toffset'));
  end
  
  % Make an analysis object
  a.data = ts;
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set the object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits'});
  
end

