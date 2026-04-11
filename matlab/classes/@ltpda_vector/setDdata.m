% SETDDATA Set the property 'ddata'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'ddata'.
%
% CALL:              obj.setDdata([1 2 3]);
%              obj = obj.setDdata([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single ltpda_vector object.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDdata(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);

  % set 'ddata'
  obj.ddata = val;

  varargout{1} = obj;
end

