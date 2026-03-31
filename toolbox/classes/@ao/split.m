% SPLIT split an analysis object into the specified segments.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPLIT split an analysis object into the specified segments.
%
% CALL:        b = split(a, pl)
%
% INPUTS:      a  - input analysis object
%              pl - input parameter list (see below for parameters)
%
% OUTPUTS:     b  - array of analysis objects
%
%
% EXAMPLES:    1.) Split method by frequency. Get the values from 10-100 Hz
%                  pl = plist('frequencies', [10 100]);
%                  ao_new = split(a1, pl);
%
%              2.) Split method by time.
%                  Get the values from 0.0 to 1.0 Seconds AND from 1.0 to 2.5 seconds
%                  pl = plist('times', [0.0 1.0 1.0 2.5]);
%                  ao_new = split(a1, pl);
%
%              3.) Split method by samples.
%                  Get the samples from 1 to 50 AND from 150 to 200.
%                  pl = plist('samples',     [1 50 150 200]);
%                  ao_new = split(a1, pl);
%
%              4.) Split method by time length.
%                  Split the AO into pices with the same time length.
%                  By default splits this type by time length rounded to
%                  the nearest integer multiple of fs. (see 'round time'
%                  parameter)
%                  pl = plist('time length', 100);
%                  ao_new = split(a1, pl);
%
%              5.) Split method by length.
%                  Split AO into segments of length N samples
%                  pl = plist('length', 100);
%                  ao_new = split(a1, pl);
%
%              6.1) Select an interval with strings
%                   --> t0 = time('14:00:00')
%                   pl = plist('start_time', '14:00:01', ...
%                              'end_time',   '14:00:02');
%                   ao_new = split(a1, pl);
%
%                   --> t0 = time('14:00:00')
%                   pl = plist('start_time', '14:00:01', ...
%                              'duration',   '00:00:02');
%                   ao_new = split(a1, pl);
%
%                   Select an interval with seconds
%                   --> t0 = time(3)
%                   pl = plist('start_time', 5, ...
%                              'end_time',   7);
%                   ao_new = split(a1, pl);
%
%              6.2) Select an interval with time objects
%                   --> t0 = time('14:00:00')
%                   pl = plist('start_time', time('14:00:01'), ...
%                              'end_time',   time('14:00:03'));
%                   ao_new = split(a1, pl);
%
%                   --> t0 = time(3)
%                   pl = plist('start_time', time(5), ...
%                              'duration',   time(2));
%                   ao_new = split(a1, pl);
%
%              6.3) Select an interval with a time span object
%                   --> t0 = time('14:00:00')
%                   ts = timespan('14:00:00', '14:00:05');
%                   pl = plist('timespan', ts);
%                   ao_new = split(a1, pl);
%                   ao_new = split(a1, ts);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'split')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = split(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### split cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pli, ~, rest]        = utils.helper.collect_objects(rest(:), 'plist', in_names);
  ts                    = utils.helper.collect_objects(rest(:), 'timespan', in_names);
  
  % copy input plist
  pl = combine(pli, plist);
  % combine input plists (if the input plists are more than one)
  pl = parse(pl);
  
  % Unpack parameter list
  split_type = find_core(pl, 'split_type');
  
  % Set 'split_type' if some other key-word is set.
  if pl.isparam_core('samples')
    split_type = 'samples';
  elseif pl.isparam_core('gap threshold') 
    split_type = 'gaps';
  elseif pl.isparam_core('times') || pl.isparam_core('frequencies') || pl.isparam_core('offsets')
    split_type = 'times';
  elseif pl.isparam_core('time length')
    split_type = 'time length';
  elseif pl.isparam_core('length')
    split_type = 'length';
  elseif pl.isparam_core('chunks') || pl.isparam_core('N')
    split_type = 'chunks';
  elseif pl.isparam_core('start_time') || pl.isparam_core('timespan')
    split_type = 'interval';
  elseif pl.isparam_core('match')
    split_type = 'match';
  elseif pl.isparam_core('xrange') || pl.isparam_core('yrange')
    split_type = 'slice';
  end
  
  if isempty(split_type) && isempty(ts)
    error('### please specify the key ''split_type'' in the parameter list');
  end
  
  if ~isempty(ts)
    pl.pset('timespan', ts);
    split_type = 'interval';
  end
  
  %%% go through analysis objects
  bo = [];
  
  for jj = 1:numel(as);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       splitting by time or frequency                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch lower(split_type)
      case 'gaps'
        
        objs = split_by_gaps(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        bo = [bo objs];
        
      case {'times', 'offsets', 'frequencies'}
        
        % split by times, offsets or frequencies
        objs = split_x_axis(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        bo = [bo objs];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                            splitting by samples                             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'samples'
        
        % split by samples
        objs = split_by_samples(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        bo = [bo objs];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                         splitting into time length                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'time length'
        
        % apply defaults
        pl = applyDefaults(getDefaultPlist('By time length'), pl);
        
        % split by time length
        b = split_by_time_length(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % Add to output array
        bo = [bo b];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                           splitting into length                             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'length'
        
        % apply defaults
        pl = applyDefaults(getDefaultPlist('By length'), pl);
        
        % split by length
        b = split_by_length(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % Add to output array
        bo = [bo b];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                            splitting into chunks                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'chunks'
        
        % apply defaults
        pl = applyDefaults(getDefaultPlist('By chunks'), pl);
        
        % split by chunks
        b = split_by_chunks(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % Add to output array
        bo = [bo b];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                           splitting into interval                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'interval'
        
        
        % split by interval
        b = split_by_interval(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % Add to output array
        bo = [bo b];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                           splitting by matching                             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'match'
        
        
        % split by matching
        b = split_by_matching(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % Add to output array
        bo = [bo b];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                           splitting by slices                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case 'slice'
        
        % is this a 3D ao?
        if ~isa(as(jj).data, 'data3D')
          warning('Input object [%s] is not a 3D data and will not be split by slicing', as(jj).name);
          continue;
        end
        
        % split by slicing
        b = split_by_slice(as(jj), pl, callerIsMethod, ao_invars{jj}, as(jj).hist);
        
        % add to output array
        bo = [bo b];        
        
      otherwise
        error('### Unknown split type %s', split_type);
        
    end % switch lower(split_type)
    
  end % numel as
  
  % The split_by_time_length() part needs for the rebuild method a
  % posibillity to select the return object.
  if ~isempty(pl.find_core('select object'))
    idx = pl.find_core('select object');
    bo = bo(idx);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bo);
  
end

function bo = split_by_slice(obj, pl, callerIsMethod, ao_invar, inhist)
  
  % ensure the input is copied since we will modify it here
  obj = copy(obj, 1);
  
  % Get sample selection from plist
  yrange = find_core(pl, 'yrange');
  xrange = find_core(pl, 'xrange');
  
  if ~isempty(xrange) && numel(xrange) ~= 2
    error('Please provide a 2-element vector for the xrange: [start stop]');
  end
  
  if ~isempty(yrange) && numel(yrange) ~= 2
    error('Please provide a 2-element vector for the yrange: [start stop]');
  end
    
  % select x segment
  if ~isempty(xrange)
    xidx = find(obj.x >= xrange(1) & obj.x < xrange(2));
    if isempty(xidx)
      error('Failed to find any data within the specified x range %s', mat2str(xrange));
    end
    x = obj.data.x;
    x = x(xidx);
    obj.data.setX(x);
    z = obj.data.z;
    z = z(:, xidx);
    obj.data.setZ(z);
    
    dx = obj.data.dx;
    if ~isempty(dx)
      dx = dx(xidx);
    end
    obj.data.setDx(dx);
    
    dz = obj.data.dz;
    if ~isempty(dz)
      dz = dz(:, xidx);
    end
    obj.data.setDz(dz);
    
  end
  
  % select y segment
  if ~isempty(yrange)
    yidx = find(obj.y >= yrange(1) & obj.y < yrange(2));
    if isempty(yidx)
      error('Failed to find any data within the specified y range %s', mat2str(yrange));
    end
    y = obj.data.y;
    y = y(yidx);
    obj.data.setY(y);
    z = obj.data.z;
    z = z(yidx, :);
    obj.data.setZ(z);
    
    dy = obj.data.dy;
    if ~isempty(dy)
      dy = dy(yidx);
    end
    obj.data.setDy(dy);
    
    dz = obj.data.dz;
    if ~isempty(dz)
      dz = dz(yidx, :);
    end
    obj.data.setDz(dz);
    
  end
  
  if ~callerIsMethod
    % Add history
    obj.addHistory(getInfo('None'), pl, {ao_invar}, inhist);
  end
  
  % set output
  bo = obj;
  
end



function bo = split_by_matching(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  % initialise output array
  bo = [];
  
  % get the matching objects
  matches = pl.find_core('match');
  
  % check the data are all the same
  try
    dataObjs = [matches.data]; % this will fail if the class of the data objects differs
  catch Me
    error('The match objects should be all the same data type. [%s]', Me.message);
  end
  
  % we split the input object by each time range of the match objects
  for kk=1:numel(matches)
    
    % use this match object
    m   = matches(kk);
    
    switch class(dataObjs(1))
      case 'tsdata'
        
        % define start/stop
        ts = m.t0 + m.x(1);
        te = m.t0 + m.x(1) + m.nsecs;
        % create split plist
        spl = plist('start_time', ts, 'end_time', te);
        
      case 'fsdata'
        
        % define f1 and f2
        df  = median(diff(m.x));
        f1  = m.x(1);
        f2  = m.x(end) + df; % ensure we include the last point
        % create split plist
        spl = plist('frequencies', [f1 f2]);
        
      otherwise
        error('Can''t split by objects of type [%s]', class(dataObjs(1)));
    end
    
    % split with the new plist
    b = split(obj, spl);
    
    if ~callerIsMethod
      % create new output history
      b.addHistory(getInfo('None'), plist('match', m), {ao_invar}, inhist);
      % set name
      b.name = ao_invar;
    end
    
    % cache this for output
    bo = [bo b];
  end % End loop over matches
  
end


function bo = split_by_gaps(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  utils.helper.msg(msg.PROC1, 'splitting [%s] by gaps', obj.name);
  
  % get gap threshold
  thresh = find_core(pl, 'gap threshold');
  threshT = thresh/obj.fs;
  
  if isempty(thresh)
    error('Please specify a gap threshold, e.g., 1.2, which defines the mulitple of the sample time which represents a gap');
  end
  
  % find gaps
  dx = diff(obj.x);
  idx = find(dx>=threshT);
  
  times = [];
  Ngap = numel(idx);
  for kk=1:Ngap
    
    % each gap generates two segments
    
    % generate start and stop but make sure the times are well inside the
    % gap by adding a sample.
    if isempty(times)
      gstart = obj.x(1);
    else
      gstart = times(end);
    end
    gend = obj.x(idx(kk)) + 1/obj.fs;
    if gend <= gstart
      gend = gstart;
    end
    times = [times gstart gend];
    
    % generate next start and stop time
    gstart = gend + dx(idx(kk)) - 1/obj.fs;
    
    if kk == Ngap
      gend = obj.x(end);
    else
      gend = obj.x(idx(kk+1)) + 1/obj.fs;
    end
    
    times = [times gstart gend];
  end
  
  bo = obj.split(plist('times', times));
  
end

function bo = split_x_axis(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  % initialise output array
  bo = [];
  
  if isa(obj.data, 'tsdata')
    % object is evenly sampled?
    evenlySampled = obj.data.evenly;
    fs_orig = obj.data.fs;
  end
  
  times       = find_core(pl, 'times');
  offsets     = find_core(pl, 'offsets');
  frequencies = find_core(pl, 'frequencies');
  
  % initialise the data offset to 0
  toffset = 0;
  
  if ~isempty(times)
    utils.helper.msg(msg.PROC1, 'splitting [%s] by time', obj.name);
    split_x_axis.type  = 'times';
    split_x_axis.value =  times;
    if ~(isa(obj.data, 'tsdata') || isa(obj.data, 'xydata'))
      warning('off', 'backtrace');
      warning('Can not process AO with data class [%s] with specified times - object will copied and passed out unmodified.', class(obj.data));
      warning('on', 'backtrace');
      bo = obj.copy(true);
      return;
    end
    
    
  elseif ~isempty(offsets)
    
    utils.helper.msg(msg.PROC1, 'splitting [%s] by offsets', obj.name);
    split_x_axis.type  = 'offsets';
    split_x_axis.value =  offsets;
    if ~(isa(obj.data, 'tsdata') || isa(obj.data, 'xydata'))
      warning('off', 'backtrace');
      warning('Can not process AO with data class [%s] with specified times - object will copied and passed out unmodified.', class(obj.data));
      warning('on', 'backtrace');
      bo = obj.copy(true);
      return;
    end
    
    if isa(obj.data, 'tsdata')
      % The offset must include the value of the first data sample 
      % x(1) AND the toffset.
      toffset = obj.x(1);
    end
    
  else
    utils.helper.msg(msg.PROC1, 'splitting [%s] by frequency', obj.name);
    split_x_axis.type  = 'frequencies';
    split_x_axis.value =  frequencies;
    if ~isa(obj.data, 'fsdata')
      warning('off', 'backtrace');
      warning('Can not process AO with data class [%s] with specified frequencies - object will be copied and passed out unmodified.', class(obj.data));
      warning('on', 'backtrace');
      bo = obj.copy(true);
      return;
    end
  end
  
  % examine time list
  ntimes = numel(split_x_axis.value);
  if mod(ntimes, 2) ~= 0
    error('### please specify a start and stop for each interval.')
  end
  % go over each interval now
  x = obj.data.getX;
  for oo=1:2:ntimes
    is = split_x_axis.value(oo);
    ie = split_x_axis.value(oo+1);
    ish = is; % Backup the start time for the history
    ieh = ie; % Backup the end time for the history
    
    % In the case of 'offsets' we support negative offsets meaning
    % count from the end and a zero end offset meaning up to the end.
    if ie < 0 && ie < is % indicates count from end
      if isa(obj.data, 'tsdata')
        ie = obj.data.nsecs + ie;
      else
        ie = x(end) + ie;
      end
      if ie < is
        ie = inf;
        warning('The end time must be later than the start time. Ingoring the end index.');
      end
    elseif ie == 0  % Go to end of vector
      if isa(obj.data, 'tsdata')
        % x(end) is to small because the find command compares only to
        % 'less' and not to 'less or equal'
        ie = x(end)+1/obj.data.fs;
      else
        % For a fsdata objs can be the 'fs' property a NaN.
        % In this case it is not usefull to add a NaN because the result
        % will be a NaN which is useless for 'ie'
        ie = x(end) + eps(x(end)); % The last term is necessary to collect also the last sample
      end
    else
      % do nothing
    end
    
    if strcmp(split_x_axis.type, 'times') && ie < is
      error('When using option ''times'' the end time must be greater than the start time');
    end
    
    % copy the data-object because we change the values.
    d = copy(obj.data, nargout);
    
    % create index of the interval
    idx = x >= is+toffset & x < ie+toffset;
    
    % Backup the errors because setting new x- or y- values with a
    % different shape will remove the errors.
    dx = obj.data.dx;
    dy = obj.data.dy;
    d.setDx([]);
    d.setDy([]);
    
    % set output data
    if isempty(d.x)
      nsamples = numel(find(x-toffset < is));
      d.setToffset(d.toffset + 1000*nsamples/d.fs);
    else
      % Here it is important to access directly the x property, because getX adds the toffset
      d.setX(x(idx));
    end
    d.setY(d.y(idx));
    
    if numel(dx) > 1
      d.setDx(dx(idx));
    end
    if numel(dy) > 1
      d.setDy(dy(idx));
    end
    if isprop(obj.data, 'enbw')
      if numel(obj.data.enbw) > 1
        d.setEnbw(obj.data.enbw(idx));
      end
    end
    
    % Set nsecs for tsdata
    if isa(d, 'tsdata')
      d.collapseX;
      
      % If we were evenly sampled before, then we are evenly sampled
      % now, so the sample rate must be the same as the original one.
      % However, we get numerical errors with all the setX, collapseX
      % stuff. Probably there's a better way to handle those cases, but
      % for now, this will have to do.....
      if evenlySampled
        d.setFs(fs_orig);
      end
    end
    
    % Copy input AO
    b = copy(obj, nargout);
    b.data = d;
    
    if ~callerIsMethod
      % create new output history
      b.addHistory(getInfo('None'), pl.pset(split_x_axis.type, [ish ieh]), {ao_invar}, inhist);
      % set name
      b.name = ao_invar;
    end
    % Add to output array
    bo = [bo b];
  end
end

function bo = split_by_samples(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  utils.helper.msg(msg.PROC1, 'splitting [%s] by samples', obj.name);
  
  % examine time list
  samples = find_core(pl, 'samples');
  npairs  = length(samples);
  if mod(npairs, 2) ~= 0
    error('### please specify a start and stop for each interval.')
  end
  
  % check data
  if isa(obj.data, 'data2D') && length(obj.data.getX) ~= length(obj.data.getY)
    error('### Something is wrong with the x/y vectors. I can''t split this data.');
  end
  
  bo = [];
  
  if isa(obj.data, 'tsdata')
    % object is evenly sampled?
    evenlySampled = obj.data.evenly;
    fs_orig = obj.data.fs;
  end
  
  % go over each interval now
  for oo=1:2:npairs
    is = samples(oo);
    ie = samples(oo+1);
    
    utils.helper.msg(msg.PROC1, sprintf('Split: %03d [%d..%d]', (oo+1)/2, is, ie));
    
    % copy the data object.
    d = copy(obj.data, nargout);
    
    % get the Y
    y = d.getY;
    
    if isa(d, 'cdata')
      
      % Memorise the error because setting the new value will remove the
      % error because the data size may not match to the error size.
      dy = d.getDy();
      if numel(dy) > 1, d.setDy([]); end
      
      y = ao.split_samples_core(y, [is ie]);
      d.setY(y);
      if numel(dy) > 1
        dy = ao.split_samples_core(dy, [is ie]);
        d.setDy(dy);
      end
      
    else
      % Memorise the error because setting the new value will remove the
      % error because the data size may not match to the error size.
      dy = d.getDy();
      dx = d.getDx();
      if numel(dy) > 1, d.setDy([]); end
      if numel(dx) > 1, d.setDx([]); end
      
      x = d.getX;
      % set new samples
      % Here it is important to access directly the x property, because getX adds the toffset
      y = ao.split_samples_core(y, [is ie]);
      x = ao.split_samples_core(x, [is ie]);
      
      d.setXY(x, y);
      % set 'dx' and 'dy' and 'enbw'
      if numel(dx) > 1
        dx = ao.split_samples_core(dx, [is ie]);
        d.setDx(dx);
      end
      if numel(dy) > 1
        dy = ao.split_samples_core(dy, [is ie]);
        d.setDy(dy);
      end
      if isprop_core(d, 'enbw')
        if numel(d.enbw) > 1
          enbw = d.enbw;
          enbw = ao.split_samples_core(enbw, [is ie]);
          d.setEnbw(enbw);
        end
      end
      % if this is tsdata, we can collapse it again, maybe
      if isa(d, 'tsdata')
        d.collapseX();
        
        % If we were evenly sampled before, then we are evenly sampled
        % now, so the sample rate must be the same as the original one.
        % However, we get numerical errors with all the setX, collapseX
        % stuff. Probably there's a better way to handle those cases, but
        % for now, this will have to do.....
        if evenlySampled
          d.setFs(fs_orig);
        end
      end
    end
    
    % Copy input AO
    b = copy(obj, nargout);
    b.data = d;
    
    % set procinfo
    b.procinfo = plist('indexes', [is ie]);
    
    if ~callerIsMethod
      % create new output history
      b.addHistory(getInfo('None'), pl.pset('samples', [is ie]), {ao_invar}, inhist);
      % set name
      b.name = sprintf('%s[%d]', ao_invar,(oo+1)/2);
    end
    % Add to output array
    bo = [bo b];
  end
end

function b = split_by_time_length(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  timeLength = pl.find_core('time length');
  roundTime  = pl.find_core('round time');
  
  % Check inputs
  if isempty(timeLength)
    error('### Please specify the ''time length'' in the parameter list.');
  end
  if ~isa(obj.data, 'tsdata')
    warning('off', 'backtrace');
    warning('Can not process AO with data class [%s] with specified time length - object will copied and passed out unmodified.', class(obj.data));
    warning('on', 'backtrace');
    b = obj.copy(true);
    return;
  end
  
  if roundTime
    % generate list of indices
    samples = round(obj.data.fs*timeLength);
    y1   = 1;
    yEnd = length(obj.data.getY);
    is = y1:samples:yEnd;
    ie = samples:samples:yEnd; if isempty(ie), ie = yEnd; end
    N  = numel(ie);
    ss = sort([is(1:N) ie]);
    
    utils.helper.msg(msg.PROC1, sprintf('Split by time length rounded to the nearest integer multiple of fs [%f]', samples/obj.data.fs));
    splitKey = 'samples';
  else
    y1   = obj.data.getX(1);
    yEnd = obj.data.getX(end) + 1/obj.data.fs;
    is = y1:timeLength:yEnd;
    ie = y1+timeLength:timeLength:yEnd; if isempty(ie), ie = yEnd; end
    N  = numel(ie);
    ss = sort([is(1:N) ie]);
    
    utils.helper.msg(msg.PROC1, sprintf('Split by time length [%f]', timeLength));
    splitKey = 'times';
  end
  
  % one call to split with these samples
  b = split(obj, plist(splitKey, ss));
  
  for kk=1:numel(b)
    % set procinfo
    b(kk).procinfo = plist(splitKey, [ss(kk) ss(kk+1)]);
    % set name
    b(kk).name = sprintf('%s[%d]', ao_invar, kk);
    if ~callerIsMethod
      % define history PLIST
      plh = combine(plist('select object', kk), pl);
      % create new output history
      b(kk).addHistory(getInfo('None'), plh, {ao_invar}, inhist);
    end
  end
  
end

function b = split_by_length(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  l = pl.find_core('length');
  
  % Check inputs
  if isempty(l)
    error('### Please specify the ''length'' in the parameter list.');
  end
  if mod(l,1)~=0 || l<1
    error('### The parameter ''length'' must be an integer and positive.');
  end
  
  utils.helper.msg(msg.PROC1, sprintf('Split AO into segments of length [%d] samples.', l));
  
  % generate list of indices
  ly = length(obj.data.getY);
  is = 1:l:ly;
  ie = l:l:ly; if isempty(ie), ie = ly; end
  N = numel(ie);
  ss = sort([is(1:N) ie]);
  
  % one call to split with these samples
  newPl = plist('split_type', 'samples', 'samples', ss);
  if callerIsMethod
    b = split(obj, newPl);
  else
    b = ltpda_run_method(@split, obj, newPl);
    
    % The ltpda_run_method method doesn't keep the variable names so
    % that we have to set the name again.
    newNames = strrep({b.name}, 'unknown', ao_invar);
    b.setName(newNames{:});
  end
  
end

function b = split_by_chunks(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  N = find_core(pl, 'N');
  if isempty(N)
    N = pl.find_core('chunks');
  end
  match = pl.find_core('match');
  utils.helper.msg(msg.PROC1, 'splitting [%s] into %d chunks', obj.name, N);
  
  y = obj.data.getY;
  
  % chunk size
  csize = floor(length(y)/N);
  
  % Verify that each chunk have at least one sample.
  if csize < 1
    error('### Please reduce the number of chunks because at the moment have each chunk less than one sample. Max number of chunks [%d]', length(y));
  end
  
  % generate list of indices
  is = 1:csize:length(y);
  ie = csize:csize:length(y);
  
  idx = sort([is(1:N) ie(1:N)]);
  
  if match == true
    idx(end) = length(y);
  end
  
  % one call to split with these samples
  newPl = plist('split_type', 'samples', 'samples', idx);
  if callerIsMethod
    b = split(obj, newPl);
  else
    b = ltpda_run_method(@split, obj, newPl);
    
    % The ltpda_run_method method doesn't keep the variable names so
    % that we have to set the name again.
    newNames = strrep({b.name}, 'unknown', ao_invar);
    b.setName(newNames{:});
  end
  
end

function out = split_by_interval(obj, pl, callerIsMethod, ao_invar, inhist)
  
  import utils.const.*
  
  %%% get values from the parameter list
  duration   = find_core(pl, 'duration');
  start_time = find_core(pl, 'start_time');
  end_time   = find(pl, 'stop_time', find_core(pl, 'end_time'));
  time_span  = find_core(pl, 'timespan');
  
  %%% Some checks
  if (~isempty(start_time) || ~isempty(end_time)) && ~isempty(time_span)
    error('### Please specify only a timespan and not additionally the start/end time');
  end
  
  %%% Skip an AO if the data is not a time-series object
  if ~isa(obj.data, 'tsdata')
    warning('off', 'backtrace');
    warning('Can not process AO with data class [%s] with specified interval - object will copied and passed out unmodified.', class(obj.data));
    warning('on', 'backtrace');
    out = obj.copy(true);
    return
  end
  
  if isa(time_span, 'history')
    % The timespan object may have been replaced with its history in
    % the previous loop exection in the call to ao/addHistory
    time_span = rebuild(time_span);
    pl.pset('timespan', time_span);
  end
  
  %%% Convert the start_time into a time object
  if ~isempty(start_time) && ~isa(start_time, 'time')
    start_time = time(start_time);
  end
  
  %%% Convert the end_time into a time object
  if ~isempty(end_time) && ~isa(end_time, 'time')
    end_time = time(end_time);
  end
  
  %%% Convert the duration
  if ~isempty(end_time) && ~isempty(duration)
    error('### Please specify only a duration or an end time');
  end
  if ~isempty(duration)
    duration = time(duration);
    end_time = start_time + duration;
    end_time = time(end_time);
  end
  
  %%% Set start/end time with a timespan object
  
  if ~isempty(time_span)
    if ~isa(time_span, 'timespan')
      error('### The timespan must be a timespan object')
    end
    if ~isempty(start_time) || ~isempty(end_time)
      error('### Please specify only a timespan OR a start/end time');
    end
    
    start_time = [time_span.getStartT];
    end_time   = [time_span.getEndT];
  end
  
  t0_time = obj.data.t0;
  
  out = [];
  
  % object is evenly sampled?
  evenlySampled = obj.data.evenly;
  fs_orig = obj.data.fs;
  
  for kk = 1:numel(start_time)
    
    %%% Compute the start/end time
    ts = double(start_time(kk) - t0_time);
    te = double(end_time(kk) - t0_time);
    
    x = obj.data.getX();
    idx = x >= ts & x < te;
    
    %%% create new output data
    d = copy(obj.data, nargout);
    
    % Backup 'dx', 'dy' and 'enbw' and set to empty array
    dx = d.getDx;
    dy = d.getDy;
    d.setDx([]);
    d.setDy([]);
    if isprop_core(d, 'enbw')
      enbw = d.enbw;
      d.setEnbw([]);
    else
      enbw = [];
    end
    
    % set output data
    if isempty(d.x)
      % Convert toffset to s
      toffset = d.toffset/1e3;
      if toffset <= ts
        % set toffset rounding at a multiplier of the sampling interval
        dN = (ts - toffset)*d.fs;
        r = round(dN) - dN;
        % Allow some numerical jitter: say 0.1% of one sampling cycle
        if abs(r) < 0.001
          dt = round(dN)/d.fs;
        else
          dt = ceil(dN)/d.fs;
        end
        d.setToffset(d.toffset + 1000*dt);
      end
    else
      % Here it is important to use the couple getX/setX
      d.setX(d.getX(idx));
    end
    d.setY(d.y(idx));
    
    if (numel(dx) > 1)
      d.setDx(dx(idx));
    end
    if (numel(dy) > 1)
      d.setDy(dy(idx));
    end
    if numel(enbw) > 1
      d.setEnbw(enbw(idx));
    end
    
    % Set nsecs for tsdata
    d.collapseX;
    
    % If we were evenly sampled before, then we are evenly sampled
    % now, so the sample rate must be the same as the original one.
    % However, we get numerical errors with all the setX, collapseX
    % stuff. Probably there's a better way to handle those cases, but
    % for now, this will have to do.....
    if evenlySampled
      d.setFs(fs_orig);
    end
    
    % Copy input AO
    b = copy(obj, nargout);
    b.data = d;
    
    if numel(start_time) > 1
      % Create new history PLIST if we have more than one start time
      plh = plist('start_time', start_time(kk), 'end_time', end_time(kk));
    else
      plh = copy(pl);
    end
    
    if ~callerIsMethod
      % create new output history
      b.addHistory(getInfo('None'), plh, {ao_invar}, inhist);
      % set name
      b.name = ao_invar;
    end
    
    out = [out b];
  end
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {...
      'Default', ...
      'By Times', ...
      'By Offsets', ...
      'By Frequencies', ...
      'By Samples', ...
      'By Time Length', ...
      'By Length', ...
      'By Chunks', ...
      'By Interval Start/End', ...
      'By Interval Start/Duration', ...
      'By Interval Timespan', ...
      'By Matching', ...
      'By Gaps', ...
      'By Slice'};
    pls = [];
    for kk = 1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
  switch lower(set)
    case 'default'
      
      pl = getDefaultPlist('by times');      
      
    case 'by times'
      % Times
      p = param({'times',['Split the ao into time segments.<br>' ....
        'An array of start/stop times to split by. The times should be relative<br>', ...
        'to the object reference time (t0).']}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by offsets'
      % Times
      p = param({'offsets',['Split the ao into time segments.<br>' ....
        'An array of start/stop offsets to split by. Positive offsets are relative<br>', ...
        'to the first sample. A negative offset is ',...
        'taken from the end of the vector. <br>For example [10 -10] removes 10 seconds ',...
        'from the beginning and end of the vector. An end time of 0 indicates ',...
        'the end of the vector.']}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by frequencies'
      
      % Frequencies
      p = param({'frequencies','An array of start/stop frequencies to split by.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by samples'
      
      % samples
      p = param({'samples','An array of start/stop samples to split by.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by time length'
      
      % time length
      p = param({'time length','Split ao into segments of length N seconds.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % same length
      p = param({'round time','Rounds the time to multiple of fs (N*fs).'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      % select object
      p = param({'select object', 'This parameter is usually used by the rebuild method. With this parameter can you define the index which object of the output objects you want to get back.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by length'
      
      % length
      p = param({'length','Split ao into segments of length N samples.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by chunks'
      
      % N
      p = param({'N','Split into N contiguous pieces.'}, paramValue.EMPTY_DOUBLE);
      p.addAlternativeKey('CHUNKS');
      pl.append(p);
      
      % match
      p = param({'match','Define if the last chunk should keep any remaining data samples.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
    case 'by interval start/end'
      
      % start_time
      p = param({'start_time','Start time can be either a string or a time object.'}, {1, {time(0)}, paramValue.OPTIONAL});
      pl.append(p);
      
      % end_time
      p = param({'end_time','End time can be either a string or a time object.'}, {1, {time(0)}, paramValue.OPTIONAL});
      pl.append(p);
      
    case 'by interval start/duration'
      
      % start_time
      p = param({'start_time','Start time can be either a string or a time object.'}, {1, {time(0)}, paramValue.OPTIONAL});
      pl.append(p);
      
      % duration
      p = param({'duration','Duration can be either a string or a time object.'}, {1, {time(0)}, paramValue.OPTIONAL});
      pl.append(p);
      
    case 'by interval timespan'
      
      % timespan
      p = param({'timespan','The start/end time are specified in the time span object.'}, {1, {timespan(0,0)}, paramValue.OPTIONAL});
      pl.append(p);
      
    case 'by matching'
      
      % match
      p = param({'match','Give an array of input AOs which will form the template for the output AOs. If time-series AOs are given, the data will be split according to the times in these AOs. Similarly, if frequency series AOs are given, the data will be split on the frequencies of these inputs.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by gaps'

      p = param({'gap threshold', ['Split the ao into segments separated by detected gaps. A gap is detected as a jump in time from one sample to another of more than threshold/fs.']}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    case 'by slice'
      
      p = param({'yrange', 'Specify a 2-vector [start stop] for the section to select from the y values.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      p = param({'xrange', 'Specify a 2-vector [start stop] for the section to select from the x values.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
    otherwise
      error('### Unknown parameter set [%s].', set);
  end
  
end

% END
