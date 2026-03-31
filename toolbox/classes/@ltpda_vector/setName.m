% SETNAME Set the property 'name'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'y'.
%
% CALL:              obj.setName(name);
%
% INPUTS:      obj - must be a single ltpda_vector object.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setName(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  if ~ischar(val)
    error('### The value for the name of the axis must be a string but it is a [%s]', class(val));
  end
  
  % set 'name'
  obj.name = val;
  
  varargout{1} = obj;
end

