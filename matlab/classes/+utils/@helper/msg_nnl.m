% MSG_NNL writes a message to the MATLAB terminal without a new line character
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Writes a message to the MATLAB terminal if its priority is
%              equal or higher than the verbosity level in the LTPDA user
%              preferences. The message can be a printf format string that
%              describes how subsequent argument sare converted for output.
%              This method doesn't add a new line character at the end of
%              the message.
%
% CALL:     utils.helper.msg(priority, message, ...)
%
% INPUTS:
%           priority - priority of the message as defined in utils.const.msg
%           message  - message string to print
%
% EXAMPLE:
%
%     >> import utils.const.*
%     >> utils.helper.msg(msg.IMPORTANT, 'The Answer is %d.', 42);
%
% NOTE: The verbosity level can be set within the 'LTPDAprefs' dialog, or via
%
%     >> LTPDAprefs('Display', 'verboseLevel', 3)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = msg_nnl(varargin)
  
  % get prefereces
  persistent setLevel;
  persistent prefs;
  
  % It is possible to reset persistent variables inside a function by using
  % the command: "clear FUNCTIONS". That means for this function (it is
  % more complicated for a package) is the command: "clear +utils/@helper/msg_nnl"
  
  % now check if we need to access the preferences and cache them.
  if isempty(setLevel)
    prefs = getappdata(0, 'LTPDApreferences');
    setLevel = double(prefs.getDisplayPrefs.getDisplayVerboseLevel);
  end
  
  
  % decide to print or not
  level = varargin{1};
  if level <= setLevel
    
    % format message
    msg = sprintf(varargin{2}, varargin{3:end});
%     msg = [repmat(char(32), 1, 2*level) msg];
    
  else
    
    msg = '';
    
  end
  
  if nargout > 0
    varargout{1} = msg;
    if nargout > 1
      varargout{2} = level;
    end
  else
    fprintf('%s', msg)
  end
  
end

