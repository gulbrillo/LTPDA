% cb_verboseLevelChanged callback if the user change the verbose level
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: java PlainDocument)
%       third  - Event Object (here: DefaultDocumentEvent)
%

function cb_timeformatChanged(varargin)
  
  % Clear the persistent variables in the time constructor.
  % Especially the 'val' in get.timeformat
  clear time
  
end
