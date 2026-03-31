% SETX Set the property 'x'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'x'.
%
% CALL:              obj.setX([1 2 3]);
%              obj = obj.setX([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setX(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  % Check if the x-axis already exist or not.
  if isempty(obj.xaxis)
    createXaxis(obj);
  end
  
  % set 'x'
  obj.xaxisDataWillChange(val);
  obj.xaxis.setData(val);
  obj.xaxisDataDidChange(val);
  
  varargout{1} = obj;
end
