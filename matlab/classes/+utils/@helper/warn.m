% WARN - prints the warning message to the MATLAB terminal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WARN - prints the warning message to the MATLAB terminal if
%              its priority is equal or higher than the verbosity level in
%              the LTPDA user preferences. The message can be a printf
%              format string that describes how subsequent argument sare
%              converted for output.
%
% CALL:        utils.helper.warn(lvl, message)
%
% INPUTS:      lvl     - priority level of the message as defined in utils.const.msg
%              message - the warning message string to print
%
% EXAMPLE:
%
%     import utils.const.*
%     utils.helper.warn(msg.DEBUG, '%f is not the answer to life the universe and everything!', 37);
%

function warn(varargin)
  
  % get prefereces
  persistent setLevel;
  persistent prefs;
  
  % It is possible to reset persistent variables inside a function by using
  % the command: "clear FUNCTIONS". That means for this function (it is
  % more complicated for a package) is the command: "clear +utils/@helper/warn"
  
  % now check if we need to access the preferences and cache them.
  if isempty(setLevel)
    prefs = getappdata(0, 'LTPDApreferences');
    setLevel = double(prefs.getDisplayPrefs.getDisplayVerboseLevel);
  end
  
  % decide to print or not
  level = varargin{1};
  if level <= setLevel
    warning(varargin{2:end});
  end
  
end

