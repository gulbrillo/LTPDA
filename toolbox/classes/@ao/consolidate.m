% CONSOLIDATE resamples all input AOs onto the same time grid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CONSOLIDATE resamples all input AOs onto the same time grid and truncates all
%             time-series to start at the maximum start time of the inputs and end
%             at the minimum stop time of the inputs.
%
% ALGORITHM:
%             1) Drop duplicate samples (ao.dropduplicates)
%             2) Interpolate missing samples (ao.interpmissing)
%             3) Fix uneven sample rate using interpolate (ao.fixfs)
%             4) Resample to same fs, either max or specified (ao.resample
%                or ao.interp depending on ratio of old and new sample
%                rate)
%             5) Truncate all vectors to minimum overlap of time-series
%                (ao.split)
%             6) Resample on to the same timing grid (ao.interp)
%             7) Truncate all vectors to same number of samples to correct for
%                any rounding errors in previous steps (ao.select)
%
% CALL:       >> bs = consolidate(as)
%
% INPUTS:     as  - array of time-series analysis objects
%             pl  - parameter list (see below)
%
% OUTPUTS:    bs  - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'consolidate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = consolidate(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Check if this was called as a modifier
  if nargout == 0
    error('### Consolidate cannot be used as a modifier. Please give an output variable.');
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  na = numel(bs);
  
  % Get only tsdata AOs with data in them
  inhists = [];
  processIdx = [];
  for jj = 1:na
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! Skipping AO %s - it''s not a time-series AO.', bs(jj).name);
    elseif bs(jj).len == 0
      warning('!!! Skipping AO %s - it has no data.', bs(jj).name);
    else
      processIdx = [processIdx jj];
      % gather the input history objects
    end
    inhists = [inhists bs(jj).hist];
  end
  toProcess = bs(processIdx);
  na = numel(toProcess);
  
  % If fs is specified, use it. Otherwise, use max of all
  % input AOs.
  fs = find_core(pl, 'fs');
  if isempty(fs)
    % compute max fs
    fs = 0;
    for jj = 1:na
      if toProcess(jj).data.fs > fs
        fs = toProcess(jj).data.fs;
      end
    end
  end
  utils.helper.msg(msg.PROC2, '----- resampling all time-series to an fs of %f', fs);
  
  %----------------- Drop all repeated samples
  utils.helper.msg(msg.PROC1, 'drop duplicates');
  for jj = 1:na
    utils.helper.msg(msg.PROC2, 'processing %s', toProcess(jj).name);
    dropduplicates(toProcess(jj), pl.subset(ao.getInfo('dropduplicates').plists.getKeys));
  end
  
  %----------------- Interpolate all missing samples
  utils.helper.msg(msg.PROC1, '----- interpolate missing samples');
  for jj = 1:na
    utils.helper.msg(msg.PROC2, 'processing %s', toProcess(jj).name);
    interpmissing(toProcess(jj), plist('method', find_core(pl, 'interp_method')));
  end
  
  %----------------- Fix uneven sampling
  utils.helper.msg(msg.PROC1, '----- fixing uneven sample rates');
  for jj = 1:na
    utils.helper.msg(msg.PROC2, 'processing %s', toProcess(jj).name);
    fixfspl = plist(...
      'method', find_core(pl, 'fixfs_method'), ...
      'interpolation', find_core(pl, 'interp_method'), ...
      'fs', fs, ...
      'filter', find_core(pl, 'filter') ...
      );
    
    fixfs(toProcess(jj), fixfspl);
  end
  
  %----------------- Resample all vectors to same fs
  utils.helper.msg(msg.PROC1, '----- resample to same fs');
  
  for jj = 1:na
    % Check if the object 'fs' is different to the new 'fs'
    if ~isequal(fs,toProcess(jj).data.fs)
      utils.helper.msg(msg.PROC2, 'resampling %s from %0.10g to %0.10g [dFs = %g]', toProcess(jj).name, toProcess(jj).fs, fs, toProcess(jj).fs-fs);
      
      % Check the resampling factor
      [P,Q] = utils.math.intfact(fs,toProcess(jj).data.fs);
      if P > 100 || Q > 100
        utils.helper.msg(msg.PROC2, 'resampling factor too high [%g/%g]. Trying interpolation', P, Q);
        % At this stage, the data should be evenly sampled
        
        % Compute the new time vector which spans the full time of the original input data.
        % orig:  |----|----|----|----
        % new:   |--------|--------|--------
        t = (0:(toProcess(jj).nsecs*fs)).'/fs + toProcess(jj).x(1);
        interp(toProcess(jj), plist('vertices', t, ...
                                    'method', find_core(pl, 'interp_method')));
      else
        resample(toProcess(jj), plist('fsout', fs));
      end
    end
  end
  
  %---------------- Time properties of AOs
  if pl.find('truncate')
    
    firstT0 = time(1e10);
    for jj = 1:na
      % Find first t0
      if toProcess(jj).t0 < firstT0;
        firstT0 = toProcess(jj).t0;
      end
    end
    
    start   = -Inf;
    stop = Inf;
    for jj = 1:na
      % Find max start time
      dstart = (toProcess(jj).data.t0.double - firstT0.double) + toProcess(jj).data.getX(1);
      if dstart > start
        start = dstart;
      end
      
      % Find min stop time
      dstop = (toProcess(jj).data.t0.double - firstT0.double) + toProcess(jj).data.getX(end) + 1/toProcess(jj).fs;
      if dstop < stop
        stop = dstop;
      end
    end
    
    %----------------- Truncate all vectors
    utils.helper.msg(msg.PROC1, '----- truncate all vectors');
    utils.helper.msg(msg.PROC2, 'truncating vectors on interval [%.4f,%.4f]', start, stop);
    
    % split each ao
    toProcess = split(toProcess, plist('timespan', timespan(start, stop) + firstT0));
    
    %----------------- Resample all vectors on to the same grid
    utils.helper.msg(msg.PROC1, 'resample to same grid');
    % compute new time grid
    
    % get the grid from the first AO
    for jj = 1:na
      toff = start - (toProcess(jj).t0.double - firstT0.double);
      t    = tsdata.createTimeVector(fs, toProcess(jj).nsecs) + toff;
      if utils.helper.eq2eps(t(1), toProcess(jj).x(1))
        % No need to act in this case
      else
        % N = length(toProcess(jj).data.getX);
        % t = linspace(toff, toff+(N-1)/fs, N);
        interp(toProcess(jj), plist('vertices', t, ...
                                    'method', find_core(pl, 'interp_method')));
      end
    end
    
    % Now ensure that we have the same data length
    ns = realmax;
    for jj = 1:na
      if len(toProcess(jj)) < ns
        ns = len(toProcess(jj));
      end
    end
    
    toProcess = select(toProcess, 1:ns);
    
    nsecs = [];
    for jj = 1:na
      if isempty(nsecs)
        nsecs = toProcess(jj).data.nsecs;
      end
      if abs(nsecs - toProcess(jj).data.nsecs)./nsecs > 1e-14
        error('### Something went wrong with the truncation. Vectors don''t span the same time period.');
      end
    end
    
  end % End 'truncate' step
  
  % Now ensure all objects have the same t0, by changing the toffset if
  % necessary.
  T0 = toProcess(1).t0;  
  for kk=2:numel(toProcess)
    toff = double(T0 - toProcess(kk).t0);
    toProcess(kk).setT0(T0);
    toProcess(kk).setToffset(toProcess(kk).toffset - toff);    
  end
  
  
  % Now set back the processed objects to the output data vector (this is
  % needed because some of the methods called above can't work as
  % modifiers).
  bs(processIdx) = toProcess;
  
  %----------------- Set history on output AOs
  for jj = 1:numel(bs);
    bs(jj).name = sprintf('%s(%s)', mfilename, ao_invars{jj});
    bs(jj).addHistory(getInfo('None'), pl.pset('fs', fs), ao_invars(jj), inhists(jj));
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
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
  ii.setModifier(false);
  ii.setArgsmin(2);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl_default = buildplist()
  pl_default = combine(...
    plist({'fs','The target sampling frequency for consolidate'}, paramValue.EMPTY_DOUBLE),...
    plist({'interp_method', 'The method for the interpolation step'}, {2, {'nearest', 'linear', 'spline', 'cubic'}, paramValue.SINGLE}), ...
    plist({'fixfs_method', 'The method for the fixfs step'}, {1, {'Time', 'Samples'}, paramValue.SINGLE}), ...
    plist({'truncate', 'Truncate final data set to the shortes overlapping interval.'}, paramValue.TRUE_FALSE), ...
    ao.getInfo('dropduplicates').plists,...
    ao.getInfo('interpmissing').plists,...
    ao.getInfo('fixfs').plists);
  
end

