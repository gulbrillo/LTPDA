% SETDZ Set the property 'dz'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'dz'.
%
% CALL:              obj.setDz([1 2 3]);
%              obj = obj.setDz([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single data3D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDz(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'dz'
  obj.zaxis.setDdata(val);

  varargout{1} = obj;
end

