% HOLD applies hold to all the given axes handles.
% 
% This exists just because MATLAB's hold seems not to be able to handle an
% array of axis handles.
% 
% CALL:
%           hold(handles, ...)
% 

function hold(varargin)
  
  axhs = varargin{1};
  for kk=1:numel(axhs)
    hold(axhs(kk), varargin{2:end});
  end
  
end

