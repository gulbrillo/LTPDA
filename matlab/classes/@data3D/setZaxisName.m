% SETZAXISNAME Set the property 'z-axis name'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'z-axis name'.
%
% CALL:              obj.setZaxisName('my new z-axis name');
%              obj = obj.setZaxisName('my new z-axis name'); create copy of the object
%
% INPUTS:      obj  - Must be a single data2D object.
%              name - Name of the z-axis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setZaxisName(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'z-axis name'
  obj.zaxis.setName(val);
  
  varargout{1} = obj;
end

