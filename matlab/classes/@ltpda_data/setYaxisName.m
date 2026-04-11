% SETYAXISNAME Set the property 'y-axis name'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'y-axis name'.
%
% CALL:              obj.setYaxisName('my new y-axis name');
%              obj = obj.setYaxisName('my new y-axis name'); create copy of the object
%
% INPUTS:      obj  - Must be a single data2D object.
%              name - Name of the y-axis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setYaxisName(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'y-axis name'
  obj.yaxis.setName(val);
  
  varargout{1} = obj;
end

