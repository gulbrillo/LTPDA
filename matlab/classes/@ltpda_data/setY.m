% SETY Set the property 'y'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'y'.
%
% CALL:              obj.setY([1 2 3]);
%              obj = obj.setY([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single ltpda_data (cdata, data2D, data3D) object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setY(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  % Check if the y-axis already exist or not.
  if isempty(obj.yaxis)
    createYaxis(obj);
  end
  
  % set and check 'y'
  obj.yaxisDataWillChange(val);
  obj.yaxis.setData(val);
  obj.yaxisDataDidChange(val);
  
  varargout{1} = obj;
end

