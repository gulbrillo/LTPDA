% cb_verboseLevelChanged callback if the user change the verbose level
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: java JComboBox)
%       third  - Event Object (here: ActionEvent)
%

function cb_timezoneChanged(varargin)
  
  % Clear the persistent variables in the time constructor.
  % Especially the 'val' in get.timezone
  clear time
  
end
