% INTIMESPAN checks if an input time is inbetween a timespan.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% description: INTIMESPAN checks if an input time is inbetween a timespan.
%
% call:        b = inTimespan(ts, numeric)
%              b = inTimespan(ts, char)
%              b = inTimespan(ts, time-obj)
%              b = inTimespan(ts, plist-obj)
%              b = inTimespan(ts1, ts2, ts3, ...)
%
% inputs:      ts        - Timespan objects
%              numeric   - Epoch (unix-) time in seconds e.g. 1325426400.000
%              char      - Character string of a time    e.g. '2012-01-01 14:00:00'
%              time-obj  - Time object
%              plist-obj - Plist object
%
% outputs:     b - Binary array with the same size as the timespan objects.
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'inTimespan')">parameters description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = inTimespan(varargin)
  
  import utils.const.*
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect objects
  [ts,    ~, rest] = utils.helper.collect_objects(varargin(:), 'timespan', in_names);
  [pl,    ~, rest] = utils.helper.collect_objects(rest(:), 'plist');
  [to,    ~, rest] = utils.helper.collect_objects(rest(:), 'time');
  [tnum,  ~, rest] = utils.helper.collect_objects(rest(:), 'double');
  [tchar, ~, rest] = utils.helper.collect_objects(rest(:), 'char');
  
  % decide on a deep copy or a modify
  % this is not necessary because we don not modify the timespan object.
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Check if the user specified only one time
  plt = [];
  if ~isempty(pl.find_core('time'))
    plt = time(pl.find_core('time'));
  end
  if sum([numel(plt), numel(tnum), numel(to), ~isempty(tchar)]) > 1
    error('### This method can check only one time if it is in the time span');
  end
  
  % get the time we want to check
  if ~isempty(plt)
    t = plt;
  elseif ~isempty(to)
    t = to;
  elseif ~isempty(tnum)
    t = time(tnum);
  elseif ~isempty(tchar)
    t = time(tchar);
  else
    error('### Please define a time.');
  end
  
  startTimes = [ts.startT];
  endTimes = [ts.endT];
  
  v1 = startTimes <= t;
  v2 = endTimes >= t;
  
  vges = reshape(v1 & v2, size(ts));
  
  % set output
  if nargout == numel(vges)
    % list of outputs
    for ii = 1:numel(vges)
      varargout{ii} = vges(ii);
    end
  else
    % single output
    varargout{1} = vges;
  end
  
end


%--------------------------------------------------------------------------
% get info object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'none')
    sets = {};
    pl   = [];
  else
    sets = {'default'};
    pl   = getDefaultPlist;
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% get default plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist;
  
  p = param({'time', 'the time you want to check whether it is in the timespan'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  
end






