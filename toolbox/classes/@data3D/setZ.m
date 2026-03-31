% SETZ Set the property 'z'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'z'.
%
% CALL:              obj.setZ([1 2 3; 1 2 3]);
%              obj = obj.setZ([1 2 3; 1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single data3D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setZ(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  % Check if the z-axis already exist or not.
  if isempty(obj.zaxis)
    createZaxis(obj);
  end
  
  % set and check 'y'
  obj.zaxisDataWillChange(val);
  obj.zaxis.setData(val);
  obj.zaxisDataDidChange(val);
  
  varargout{1} = obj;
end
