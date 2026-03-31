% HUMAN returns a human readable string representing the time range.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: returns a human readable string representing the time range.
%
% CALL:                 human(t1, t2, t3,...)
%                strs = human(t1)
%                strs = human(t1, t2, t3)
%                strs = human(tN)
%
% INPUTS:      tN   - input timespan objects
%              ts   - input timespan objects array
%
% OUTPUTS:     str - returns a cell-array of strings, each string
%                    describing one input timespan.
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'human')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = human(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  if ~callerIsMethod
    % Collect all TIMESPANs
    ts = utils.helper.collect_objects(varargin(:), 'timespan');
  else
    % Assume the input is a single TIMESPAN or a vector of TIMESPANs
    ts = varargin{1};
  end

  % Create strings
  out = {};
  for jj = 1:numel(ts)
    nsecs = diff(double(ts(jj)));
    str = timespan.doubleToHumanInterval(nsecs);
    out = [out {str}];
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
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

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
