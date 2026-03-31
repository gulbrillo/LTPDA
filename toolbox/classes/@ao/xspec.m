% XSPEC performs cross-spectral analysis of various forms.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XSPEC performs cross-spectral analysis of various forms.
%              The function is a helper function for various higher level
%              functions. It is meant to be called from other functions
%              (e.g., tfe).
%
% CALL:        b = xspec(a, pl, method, iALGO, iVER, invars, isModifier, PSD_CALL, callerIsMethod);
%
% INPUTS:      a      - vector of 2 input AOs
%              pl     - input parameter list
%              method - one of
%                       'cpsd'     - compute cross-spectral density
%                       'tfe'      - estimate transfer function between inputs
%                       'mscohere' - estimate magnitude-squared cross-coherence
%                       'cohere'   - estimate complex cross-coherence
%              iALGO  - ALGONAME from the calling higher level script
%              iVER   - VERSION from the calling higher level script
%              invars - invars variable from the calling higher level script
%
% OUTPUTS:     b  - output AO
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = xspec(varargin)

  import utils.const.*

  % unpack inputs
  as             = varargin{1};
  pl             = varargin{2};
  method         = varargin{3};
  mi             = varargin{4};
  invars         = varargin{5};
  isModifier     = varargin{6};
  PSD_CALL       = varargin{7};
  callerIsMethod = varargin{8};

  %----------------- Select all AOs with time-series data
  if callerIsMethod
    tsao = as;
  else
    tsao = [];
    for ll = 1:numel(as)
      if isa(as(ll).data, 'tsdata')
        tsao = [tsao as(ll)];
      else
        warning('### xspec requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t contain this AO', invars{ll});
      end
    end

    %----------------- Gather the input history objects
    if PSD_CALL
      inhists = [tsao(1).hist];
    else
      inhists = [tsao(:).hist];
    end
  end
  
  if numel(tsao) ~= 2
    error('### XSPEC needs two time-series AOs.');
  end
  
  
  %----------------- Check the time range
  time_range = mfind(pl, 'split', 'times');
  for ll = 1:numel(tsao)
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
    if numel(tsao(ll).data.y) <= 0
      error('### I found no data in the selected time-range. Either the %d-th object is empty, or you need to revise your settings ...', ll);
    end
  end
  
  %----------------- Resample all AOs
  if PSD_CALL == false
    copies = zeros(size(tsao));
    
    fsmin = ao.findFsMin(tsao);
    fspl  = plist(param('fsout', fsmin));
    for ll = 1:numel(tsao)
      % Check Fs
      if tsao(ll).data.fs ~= fsmin
        utils.helper.msg(msg.PROC1, 'resampling AO %s to %f Hz', tsao(ll).name, fsmin);
        % Make a deep copy so we don't
        % affect the original input data
        tsao(ll) = copy(tsao(ll), 1);
        copies(ll) = 1;
        resample(tsao(ll), fspl);
      end
    end
  else
    fsmin = tsao(1).data.fs;
  end
  
  %----------------- Truncate all vectors

  % Get shortest vector
  if PSD_CALL == false
    lmin = ao.findShortestVector(tsao);
    nsecs = lmin / fsmin;
    for ll = 1:numel(tsao)
      if len(tsao(ll)) ~= lmin
        utils.helper.msg(msg.PROC2, 'truncating AO %s to %d secs', tsao(ll).name, nsecs);
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
  else
    lmin = len(tsao(1));
  end
  
  %----------------- check input parameters

  usepl = utils.helper.process_spectral_options(pl, 'lin', lmin, fsmin);

  % Loop over input AOs
  %utils.helper.msg(msg.PROC1, 'computing %s(%s -> %s)', method, invars{1}, invars{2});

  % -------- Make Xspec estimate

  % Compute xspec using welch and always scale to PSD
  if PSD_CALL
    [txy, f, info, dev] = ao.wosa(tsao(1), method, usepl);
  else    
    [txy, f, info, dev] = ao.wosa(tsao(1), tsao(2), method, usepl.pset('Scale', 'PSD'));
  end
  
  % Keep the data shape of the first input AO
  if size(tsao(1).data.y,1) == 1
    txy = txy.';
    f   = f.';
    dev = dev.';
  end
  
  % create new output fsdata
  fsd = fsdata(f, txy, fsmin);
  fsd.setEnbw(info.enbw);
  fsd.setXunits(unit.Hz);

  % perhaps this code should be handled in utils.math.welchscale
  switch lower(method)
    case 'psd'
      fsd.setYunits(info.units);
    case 'tfe'
      fsd.setYunits(tsao(2).data.yunits / tsao(1).data.yunits);
    case 'cpsd'
      fsd.setYunits(tsao(2).data.yunits * tsao(1).data.yunits / unit.Hz);
    case {'mscohere','cohere'}
      fsd.setYunits(unit());
    otherwise
      error(['### Unknown method:' method]);
  end
  
  if ~isnumeric(pl.find('nfft')) || (pl.find('nfft') > 0 && pl.find('navs') <= 0)
    utils.helper.msg(msg.MNAME, 'Number of averages set to %d', info.navs);
  end
  fsd.setNavs(info.navs);

  % Set the earliest timestamp of the input AOs to the fsdata object
  % This replaces the setting if the input t0 are the same
  if PSD_CALL
    fsd.setT0(tsao(1).data.t0 + tsao(1).x(1));
  else
    fsd.setT0(min([tsao(1).data.t0 + tsao(1).x(1), tsao(2).data.t0 + tsao(2).x(1)]));
  end
  
  % make output analysis object
  if PSD_CALL
    bs = copy(tsao(1), ~isModifier);
    bs.data = fsd;
  else
    bs = ao(fsd);
  end
  
  % add variance
  bs.data.setDy(dev);

  % drop window samples
  if usepl.find_core('Drop Window Samples')
    if isa(info.win, 'specwin')
      if info.win.skip > 0
        bs = bs.split(plist('samples', [info.win.skip+1 inf]));
      end
    end
  end
  
  % simplify the units in the case of cpsd calculation
  if ~callerIsMethod
    if strcmp(method, 'cpsd')
      bs.simplifyYunits(plist('prefixes', false, 'exceptions', 'Hz'));
    end
  end
  
  %----------- Add history

  % set name
  if ~callerIsMethod
    if PSD_CALL
      bs.name = sprintf('%s(%s)', upper(method), invars{1});
    else
      bs.name = sprintf('%s(%s->%s)', upper(method), invars{1}, invars{2});
    end
  end
  
  % we need to get the input histories in the same order tsao the inputs
  % to this function call, not in the order of the input to xspec;
  % otherwise the resulting matrix on a 'create from history' will be
  % mirrored.
  if ~callerIsMethod
    bs.addHistory(mi, usepl, [invars(:)], inhists);
  end
  
  % Propagate 'plotinfo'
  if isempty(tsao(1).plotinfo)
    if ~isempty(tsao(2).plotinfo)
      bs.plotinfo = copy(tsao(2).plotinfo, 1);
    end
  else
    bs.plotinfo = copy(tsao(1).plotinfo, 1);
  end

  % Set output
  varargout{1} = bs;
end

