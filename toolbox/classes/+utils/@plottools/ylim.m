% YLIM applies ylim to all the given axes handles.
% 
% This exists just because MATLAB's ylim seems not to be able to handle an
% array of axis handles.
% 
% CALL:
%           ylim(handles, ...)
% 

function ylim(varargin)
  
  axhs = varargin{1};
  for kk=1:numel(axhs)
    ylim(axhs(kk), varargin{2:end});
  end
  
end

