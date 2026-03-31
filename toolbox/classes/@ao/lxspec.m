% LXSPEC performs log-scale cross-spectral analysis of various forms.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LXSPEC performs log-scale cross-spectral analysis of various forms.
%              The function is a helper function for various higher level
%              functions. It is meant to be called from other functions
%              (e.g., ltfe).
%
% CALL:       b = lxspec(a, pl, method, iALGO, iVER, invars);
%
% INPUTS:     a      - vector of input AOs
%             pl     - input parameter list
%             method - one of
%                       'cpsd'     - compute cross-spectral density
%                       'tfe'      - estimate transfer function between inputs
%                       'mscohere' - estimate magnitude-squared cross-coherence
%                       'cohere'   - estimate complex cross-coherence
%             mi     - minfo object for calling method
%             invars - invars variable from the calling higher level script
%
% OUTPUTS:    b  - output AO
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lxspec(varargin)
  
  import utils.const.*
  
  % unpack inputs
  as       = varargin{1};
  pl       = varargin{2};
  method   = varargin{3};
  mi       = varargin{4};
  invars   = varargin{5};
  
  %----------------- Select all AOs with time-series data
  tsao = [];
  for ll=1:numel(as)
    if isa(as(ll).data, 'tsdata')
      tsao = [tsao as(ll)];
    else
      warning('### xspec requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t contain this AO', invars{ll});
    end
  end
  % Check if there are some AOs left
  if numel(tsao) ~= 2
    error('### LXSPEC needs two time-series AOs.');
  end
  
  %----------------- Gather the input history objects
  inhists = [tsao(:).hist];
  
  %----------------- Check the time range.
  time_range = mfind(pl, 'split', 'times');
  for ll=1:numel(tsao)
    if ~isempty(time_range)
      switch class(time_range)
        case 'double'
          tsao(ll) = split(tsao(ll), plist(...
            'times', time_range));
        case 'timespan'
          tsao(ll) = split(tsao(ll), plist(...
            'timespan', time_range));
        case 'time'
          tsao(ll) = split(tsao(ll), plist(...
            'start_time', time_range(1), ...
            'end_time', time_range(2)));
        case 'cell'
          tsao(ll) = split(tsao(ll), plist(...
            'start_time', time_range{1}, ...
            'end_time', time_range{2}));
        otherwise
      end
    end
    if tsao(ll).len <= 0
      error('### The object is empty! Please revise your settings ...');
    end
  end
  
  copies = zeros(size(tsao));
  
  %----------------- Resample all AOs
  fsmax = ao.findFsMax(tsao);
  fspl  = plist(param('fsout', fsmax));
  for ll = 1:numel(tsao)
    % Check Fs
    if tsao(ll).data.fs ~= fsmax
      utils.helper.msg(msg.PROC2, 'resampling AO %s to %f Hz', tsao(ll).name, fsmax);
      % Make a deep copy so we don't
      % affect the original input data
      tsao(ll) = copy(tsao(ll), 1);
      copies(ll) = 1;
      tsao(ll).resample(fspl);
    end
  end
  
  %----------------- Truncate all vectors
  % Get shortest vector
  lmin = ao.findShortestVector(tsao);
  nsecs = lmin / fsmax;
  for ll = 1:numel(tsao)
    if len(tsao(ll)) ~= lmin
      utils.helper.msg(msg.PROC1, 'truncating AO %s to %d secs', tsao(ll).name, nsecs);
      % do we already have a copy?
      if ~copies(ll)
        % Make a deep copy so we don't
        % affect the original input data
        tsao(ll) = copy(tsao(ll), 1);
        copies(ll) = 1;
      end
      tsao(ll).select(1:lmin);
    end
  end
  
  %----------------- Build signal Matrix
  N     = len(tsao(1)); % length of first signal
  iS    = zeros(numel(tsao), N);
  for jj = 1:numel(tsao)
    iS(jj,:) = tsao(jj).data.getY;
  end
  
  %----------------- check input parameters
  pl = utils.helper.process_spectral_options(pl, 'log');
  
  % Desired number of averages
  Kdes = find_core(pl, 'Kdes');
  % num desired spectral frequencies
  Jdes = find_core(pl, 'Jdes');
  % Minimum segment length
  Lmin = find_core(pl, 'Lmin');
  % Window function
  Win = find_core(pl, 'Win');
  % Overlap
  Nolap = find_core(pl, 'Olap')/100;
  % Order of detrending
  Order = find_core(pl, 'Order');
  
  %----------------- Get frequency vector
  [f, r, m, L, K] = ao.ltf_plan(lmin, fsmax, Nolap, 1, Lmin, Jdes, Kdes);
  
  %----------------- compute TF Estimates
  [Txy dev]= ao.mltfe(iS, f, r, m, L,K,fsmax, Win, Order, Nolap*100, Lmin, method);
  
  % Keep the data shape of the first AO
  if size(tsao(1).data.y, 1) == 1
    f   = f.';
    Txy = Txy.';
    dev = dev.';
  end
  
  %----------------- Build output Matrix of AOs
  
  % create new output fsdata
  fsd = fsdata(f, Txy, fsmax);
  fsd.setXunits(unit.Hz);
  switch lower(method)
    case 'tfe'
      fsd.setYunits(tsao(2).data.yunits / tsao(1).data.yunits);
    case 'cpsd'
      fsd.setYunits(tsao(2).data.yunits * tsao(1).data.yunits / unit.Hz);
    case {'cohere','mscohere'}
      fsd.setYunits(unit());
    otherwise
      error(['### Unknown method:' method]);
  end
  
  % Set the earliest timestamp of the input AOs to the fsdata object
  % This replaces the setting if the input t0 are the same
  fsd.setT0(min([tsao(1).t0 + tsao(1).x(1), tsao(2).t0 + tsao(2).x(1)]));
  
  % make output analysis object
  bs = ao(fsd);
  % add standard deviation to dy field
  bs.data.setDy(dev);
  % simplify the units
  if strcmp(method, 'cpsd')
    bs.simplifyYunits(plist('prefixes', false, 'exceptions', 'Hz'));
  end
  
  % set name
  bs.name = sprintf('L%s(%s->%s)', upper(method), invars{1}, invars{2});
  % set procinfo
  bs.procinfo = combine(bs.procinfo,plist('r', r, 'm', m, 'l', L, 'k', K));
  % Propagate 'plotinfo'
  if isempty(tsao(1).plotinfo)
    if ~isempty(tsao(2).plotinfo)
      bs.plotinfo = copy(tsao(2).plotinfo, 1);
    end
  else
    bs.plotinfo = copy(tsao(1).plotinfo, 1);
  end
  % Add history
  bs.addHistory(mi, pl, [invars(:)], inhists);
  
  
  % Set output
  varargout{1} = bs;
end
% END
