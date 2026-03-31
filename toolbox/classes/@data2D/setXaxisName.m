% SETXAXISNAME Set the property 'x-axis name'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'x-axis name'.
%
% CALL:              obj.setXaxisName('my new x-axis name');
%              obj = obj.setXaxisName('my new x-axis name'); create copy of the object
%
% INPUTS:      obj  - Must be a single data2D object.
%              name - Name of the x-axis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXaxisName(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'x-axis name'
  obj.xaxis.setName(val);
  
  varargout{1} = obj;
end

