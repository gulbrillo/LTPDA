% BOX applies box to all the given axes handles.
% 
% This exists just because MATLAB's box seems not to be able to handle an
% array of axis handles.
% 
% CALL:
%           box(handles, ...)
% 
function box(varargin)
  
  axhs = varargin{1};
  for kk=1:numel(axhs)
    box(axhs(kk), varargin{2:end});
  end
  
end

