% SETDATA Set the property 'data'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'data'.
%
% CALL:              obj.setData([1 2 3]);
%              obj = obj.setData([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single ltpda_vector object.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setData(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'data'
  obj.data = val;

  varargout{1} = obj;
end

