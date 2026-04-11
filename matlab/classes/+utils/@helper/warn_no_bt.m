% WARN_NO_BT - prints the warning message to the MATLAB terminal without backtrace informations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WARN_NO_BT - prints the warning message to the MATLAB terminal
%              without backtrace informations and if its priority is equal
%              or higher than the verbosity level in the LTPDA user
%              preferences. The message can be a printf format string that
%              describes how subsequent argument sare converted for output. 
%
% CALL:        utils.helper.warn_no_bt(lvl, message)
%
% INPUTS:      lvl     - priority level of the message as defined in utils.const.msg
%              message - the warning message string to print
%
% EXAMPLE:
%
%     import utils.const.*
%     utils.helper.warn_no_bt(msg.DEBUG, '%f is not the answer to life the universe and everything!', 37);
%

function warn_no_bt(varargin)
  
  % I'm using the cleanup handler because it might be that the warning
  % throws an error and then is the 'backtrace' off for all other warnings.
  warning('backtrace', 'off');
  oncleanup = onCleanup(@() warning('backtrace', 'on'));
  
  utils.helper.warn(varargin{:});
  
end

