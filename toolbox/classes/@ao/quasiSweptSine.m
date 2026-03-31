% quasiSweptSine computes a transfer function from swept-sine measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: quasiSweptSine computes a transfer function from discrete
% swept-sine measurements.
%
% In order for the calculation to work, you need to give it an array of
% start and stop times (or durations), and (optionally) an array of
% amplitudes and frequencies of the injected sine-waves. If you don't
% specify the frequencies, you must give a time-series of the injected
% signal and the algorithm will try to determine the amplitudes and
% frequencies from the data. 
% 
%
% CALL:       T = quasiSweptSine(out, pl);
%
% INPUTS:     out     - The measured output of the system
%             PL      - parameter list
%
% OUTPUT:     T   - the measured transfer function
%
% The procinfo of the output AOs contains the following fields:
% 
% 'frequencies' - the frequencies used in the DFT estimation.
% 'timespans'   - an array of timespan objects, one for each sine-wave
%                 segment
%
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'quasiSweptSine')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = quasiSweptSine(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % tell the system we are runing
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl               = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### quasiSweptSine can not be used as a modifier method. Please give at least one output');
  end
  
  % Make copies or handles to inputs
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
 
  % Parameters
  input = pl.find_core('input');
  startTimes = pl.find_core('Start times');
  stopTimes = pl.find_core('Stop times');
  durations = pl.find_core('durations');
  amplitudes = pl.find_core('amplitudes');
  frequencies = pl.find_core('frequencies');
%   phases = pl.find_core('phases');
  inUnits = pl.find_core('Input Units');
  win = pl.find_core('Win');
  Nerror = pl.find_core('Nerror');
  
  if isa(input, 'ao') && ~isa(input.data, 'tsdata')
    utils.helper.err('quasiSweptSine requires time-series as input');
  end

  
  %---------------------------------------------------
  %--------- Convert the times to timespans
  if isempty(durations) && isempty(stopTimes)
    utils.helper.err('You need to specify either an array of stop times, or an array of durations');
  end

  
  %---------------------------------------------------
  %--------- if we have the input, we use it to determine amplitudes and
  %--------- frequencies
  
  if isempty(input) && isempty(amplitudes)
    utils.helper.err('You need to specify either an input signal, or a full description of the signals including amplitudes and frequecies.');
  end
  
  computeFrequecies = false;
  if isempty(frequencies)
    computeFrequecies = true;
  end
  
  
  % Go through each ao
  for jj=1:numel(bs)
  
    
    if ~isa(bs.data, 'tsdata')
      utils.helper.err('quasiSweptSine requires time-series as input');
    end
    
    [timespans, startTimes, stopTimes] = generateTimespans(bs(jj).t0, startTimes, stopTimes, durations);
  
    
    % Go through each time-span
    Txx = zeros(size(timespans));
    dT  = zeros(size(timespans));
    for kk=1:numel(timespans)
      if isa(input, 'ao')
        inseg = input.split(plist('timespan', timespans(kk)));
      else
        % We don't have an input, so we need to create inputs from the
        % signal specs
        
        inseg = ao(plist('waveform', 'sine wave', ...
          'nsecs', timespans(kk).interval, ...
          'fs', bs(jj).fs, ...
          'A', amplitudes(kk), ...
          'f', frequencies(kk), ...
          'toff', 0, ...
          't0', startTimes(kk), ...
          'yunits', inUnits));
      end
      if computeFrequecies
        b = sineParams(inseg, plist('N', 1));
        frequencies(kk) = b.y(2);
      end
      
      utils.helper.msg(msg.PROC1, 'Computing TF at %g Hz', frequencies(kk));
      
      % Window
      w = ao(plist('win', win, 'length', inseg.len));
      
      % Output
      outseg = bs(jj).split(plist('timespan', timespans(kk)));
      
      % Compute DFT
      fs  = outseg.data.fs;
      N   = outseg.len;
      J   = -2*pi*1i.*(0:N-1)/fs;
      outxx = exp(frequencies(kk)*J)*(w.y.*outseg.data.getY);
      inxx = exp(frequencies(kk)*J)*(w.y.*inseg.data.getY);
      Txx(kk) = outxx./inxx;
      
      % Compute error
      % 
      nout = noiseAroundLine(outseg, frequencies(kk), Nerror);
      nin  = noiseAroundLine(inseg, frequencies(kk), Nerror);
      snr1 = abs(outxx)./nout;
      snr2 = abs(inxx)./nin;      
      dT(kk) = abs(Txx(kk)) * sqrt( (1./snr1)^2 + (1./snr2)^2);
      
      
    end % End loop over timespans (segments)
    
    % Make output    
    bs(jj).data = fsdata(frequencies, Txx, bs(jj).data.fs);
    bs(jj).data.setDy(dT);
    bs(jj).data.setXunits(unit.Hz);
    bs(jj).data.setYunits(outseg.yunits./inseg.yunits);
    % Set name
    bs(jj).name = sprintf('sweptsine(%s,%s)', input.name, ao_invars{jj});
    % Set procinfo
    bs(jj).procinfo = plist('frequencies', frequencies, ...
      'timespan', timespans);
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    
  end % Loop over input aos
  
  % set outputs
  varargout{1} = bs;
  
end

function n = noiseAroundLine(sig, f0, N)
  
  xx = abs(fft(sig));
  
  % get the noise floor around the frequency of interest
  % - we need the bin that is nearest the frequency
  f = abs(xx.x - f0);
  [m, mi] = min(f);
%   xx.x(mi)
%   iplot(xx)
%   plot(xx.x(mi), xx.y(mi), 'x')
  
  M = N-1;
  % Measure below the line frequency if we can
  nl = 0;
  if (mi>1) 
    ls = max(1, mi-2*M);
    le = max(1, mi-M);
    nl = xx.y(ls:le);
  end
  % Measure above the line frequency if we can
  nu = 0;
  if mi<xx.len
    us = min(xx.len, mi+M);
    ue = min(xx.len, mi+2*M);
    nu = xx.y(us:ue);
  end
  n = mean([nl;nu]);
  
end

function [ts, startTimes, stopTimes] = generateTimespans(t0, startTimes, stopTimes, durations)
  
  
  if isempty(durations) && numel(startTimes) ~= numel(stopTimes)
    utils.helper.err('You need to specify the same number of start and stop times.');
  end
  if isempty(stopTimes) && numel(startTimes) ~= numel(durations)
    utils.helper.err('You need to specify the same number of durations and stop times.');
  end
  
  
  ts = timespan.initObjectWithSize(1,numel(startTimes));
  
  % Convert to time objects
  if iscell(startTimes)
    startTimes = time(startTimes);
  end
  if isnumeric(startTimes)
    newStarts = time.initObjectWithSize(1,numel(startTimes));
    for kk=1:numel(startTimes)
      newStarts(kk) = t0+startTimes(kk);
    end
    startTimes = newStarts;
  end
  
  if isempty(durations) && iscell(stopTimes)
    stopTimes = time(stopTimes);
  end
  
  if isempty(durations) && isnumeric(stopTimes)
    if isnumeric(stopTimes)
      newStops = time.initObjectWithSize(1,numel(startTimes));
      for kk=1:numel(stopTimes)
        newStops(kk) = t0+stopTimes(kk);
      end
      stopTimes = newStops;
    end
  end
  
  useDuration = isempty(stopTimes);
  for kk=1:numel(startTimes)
    if useDuration
      ts(kk) = timespan(startTimes(kk), startTimes(kk)+durations(kk));
    else
      ts(kk) = timespan(startTimes(kk), stopTimes(kk));
    end
  end
  
end


% get info object
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

% get default plist
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  % default plist for linear fitting
  pl = plist();
  
  % Input
  p = param({'input', 'The input data series.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Start times
  p = param({'Start Times', 'A cell array of start times, or an array of time objects.'}, ...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Stop times
  p = param({'Stop Times', 'A cell array of stop times, or an array of time objects.'}, ...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Durations
  p = param({'Durations', 'An array of durations that can be used instead of the stop times.'}, ...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Amplitudes
  p = param({'Amplitudes', 'An array of amplitudes.'}, ...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Frequencies
  p = param({'Frequencies', 'An array of frequencies [Hz].'}, ...
    paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Input units
  p = param({'Input Units', 'If you don''t give an input signal AO, you can specify the units of the signal that will be constructed internally.'}, ...
    {1, {'V'}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Window
  p = param({'Win', 'A window to apply to each segment when computing the DFT.'}, ...
    paramValue.WINDOW);
  pl.append(p);
  
  % Error samples
  p = param({'Nerror', ['The number of samples either side of the line frequency to use to estimate the noise floor.'...
    'The noise is estimated from <br><br><tt>mean([y(idx-2*M:idx-M);y(idx+M:idx+2M)])</tt><br><br> where <tt>M=N-1</tt> and <tt>idx</tt> is the index '...
    'of the bin nearest to the frequency of the signal.']}, ...
    paramValue.DOUBLE_VALUE(5));
  pl.append(p);
  
%   % Phases
%   p = param({'Phases', 'An array of phases [degrees].'}, paramValue.DOUBLE_VALUE(0));
%   pl.append(p);
  
end
