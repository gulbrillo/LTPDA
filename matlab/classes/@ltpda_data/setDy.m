% SETDY Set the property 'dy'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'dy'.
%
% CALL:              obj.setDy([1 2 3]);
%              obj = obj.setDy([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single ltpda_data (cdata, data2D, data3D) object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDy(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'dy'
  obj.yaxis.setDdata(val);

  varargout{1} = obj;
end

