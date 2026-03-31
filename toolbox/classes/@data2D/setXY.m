% SETXY Set the property 'xy'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'xy'.
%
% CALL:              obj.setXY([1 2 3], [1 2 3]);
%              obj = obj.setXY([1 2 3], [1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXY(varargin)
  
  obj = varargin{1};
  x   = varargin{2};
  y   = varargin{3};
  
  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  % set 'x' and 'y'
  obj.setY(y);
  obj.setX(x);
  
  varargout{1} = obj;
end

