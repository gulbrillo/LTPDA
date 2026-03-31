% SETX Set the property 'x'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'x'.
%
% CALL:              obj.setX([1 2 3]);
%              obj = obj.setX([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single tsdata object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setX(varargin)
  
  obj = varargin{1};
  
  % In this case we have to set the toffset to 0
  obj.toffset = 0;
  
  if nargout > 0
    obj = setX@data2D(varargin{1},varargin{2:end});
  else
    setX@data2D(varargin{1},varargin{2:end});
  end
  
  if ~isempty(varargin{2:end})
    % Eventually, we have to adjust sampling rate
    % The tsdata.setFs will also set nsecs
    [fs, ~, ~] = tsdata.fitfs(varargin{2:end});
    obj.setFs(abs(fs));
  end
  
  varargout{1} = obj;
end
