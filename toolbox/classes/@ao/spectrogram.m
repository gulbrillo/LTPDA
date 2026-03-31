% SPECTROGRAM computes a spectrogram of the given ao/tsdata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPECTROGRAM computes a spectrogram of the given ao/tsdata
%              using MATLAB's spectrogram function.
%
% CALL:        b = spectrogram(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'spectrogram')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spectrogram(varargin)

  bs = [];

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

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [ps, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % Process parameters
  pl = applyDefaults(getDefaultPlist, ps);
  
  as = copy(as, nargout);

  % Check input analysis object
  for j=1:numel(as)
    a     = as(j);

    if isa(a.data, 'tsdata')
      % Get settings for this AO
      nfft = find_core(pl, 'Nfft');
      if isempty(nfft) || nfft < 0
        nfft = length(a.data.yaxis.data)/2;
      end
      
      % ensure we have an integer
      nfft = round(nfft);
      
      win  = find_core(pl, 'Win');
      if ischar(win)
        win = specwin(win);
      end
      if length(win.win) < nfft
        switch lower(win.type)
          case 'kaiser'
            win = specwin(win.type, nfft, win.psll);
          otherwise
            win = specwin(win.type, nfft);
        end
        utils.helper.msg(msg.PROC1, 'reset window to %s(%d)', strrep(win.type, '_', '\_'), length(win.win));
      end
      
      % segment overlap
      nolap = find_core(pl, 'nolap');
      if isempty(nolap) || nolap < 0
        nolap = floor(win.rov*nfft/100);
      else
        nolap = floor(nolap*nfft/100);        
      end
      
      % Process data
      freqVec = find_core(pl, 'freqVec');
      if ~isempty(freqVec) && isempty(find(freqVec < 0))
        [S, F, T, P] = spectrogram(a.y, win.win, nolap, freqVec, a.fs);
      else
        [S, F, T, P] = spectrogram(a.y, win.win, nolap, nfft, a.fs);
      end
      
      % Normalize each frequency by its median power
      if pl.find_core('normalize')  
        K = repmat(median(P,2), 1, size(P,2));
        P = P./K;
        zunits = '';
      else
        zunits = a.data.getYunits^2 / unit.Hz;
      end
      
      % Make output AO
      do = tfmap(T+a.x(1), F, P);
      do.setXunits(unit.seconds);
      do.setYunits(unit.Hz);
      do.setZunits(zunits);
      do.setT0(a.data.t0);
      do.setFs(a.data.fs);
      do.setNsecs(a.data.nsecs);
      
      a.data = do;
      a.name = sprintf('spectrogram(%s)', ao_invars{j});
      a.addHistory(getInfo('None'), pl, cellstr(ao_invars{j}), a.hist);
      
      % add to output
      bs = [bs a];
    else
      warning('!!! Skipping input AO [%s] - it is not a time-series', a.name);
      % add to output
      bs = [bs a];
    end
  end

  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  
  % Win
  p = param({'Win', 'The spectral window to apply to the data.'}, paramValue.WINDOW);
  pl.append(p);
  
  % Nolap
  p = param({'Nolap', 'The segment overlap (%).'}, {1, {-1}, paramValue.OPTIONAL});
  p.addAlternativeKey('olap');
  pl.append(p);
  
  % Nfft
  p = param({'Nfft', 'The number of samples in each short fft.'}, {1, {-1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % FreqVec
  p = param({'FreqVec', 'Vector of frequencies where to calculate the spectrogram according to the Goertzel Algorithm (optional). By default, FFT algorithm is applied; only if this parameter is set then the Goertzel Algorithm is used.'}, {1, {-1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % normalize
  p = param({'normalize', 'Normalize the spectrogram by the median power spectral density.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

% PARAMETERS:
%
%           'Win'   - a specwin object [default: Kaiser -200dB psll]
%           'Nolap' - segment overlap [default: taken from window function]
%           'Nfft'  - number of samples in each short fourier transform
%                     [default: sample rate of data]
%
