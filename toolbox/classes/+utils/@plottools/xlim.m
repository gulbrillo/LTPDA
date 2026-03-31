% XLIM applies xlim to all the given axes handles.
% 
% This exists just because MATLAB's xlim seems not to be able to handle an
% array of axis handles.
% 
% CALL:
%           xlim(handles, ...)
% 

function xlim(varargin)
  
  axhs = varargin{1};
  for kk=1:numel(axhs)
    xlim(axhs(kk), varargin{2:end});
  end
  
end

