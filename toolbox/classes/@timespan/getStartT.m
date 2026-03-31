% GETSTARTT Get the timespan property 'startT'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETSTARTT Get the timespan property 'startT'.
%
% CALL:        val = getStartT(t1, t2, t3,...)
%              val = getStartT(ts)
%              val = ts.getStartT()
%
% INPUTS:      tN   - input timespan objects
%              ts   - input timespan objects array
%
% OUTPUTS:     val  - array of time objects with 'startT', one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'getStartT')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getStartT(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  property = 'startT';
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  if ~callerIsMethod
    % Collect all TIMESPANs
    ts = utils.helper.collect_objects(varargin(:), 'timespan');
  else
    % Assume the input is a single TIMESPAN or a vector of TIMESPANs
    ts = varargin{1};
  end

  % Extract the property
  for jj = 1:numel(ts)
    if isprop(ts(jj), property)
      out(jj) = ts(jj).(property);
    else
      utils.helper.msg(msg.IMPORTANT, 'The %dth object has no %s property. Setting result to NaN', jj, property);
      out(jj) = NaN;
    end
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
