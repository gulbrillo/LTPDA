% SETARGSMIN Set the property 'argsmin'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'argsmin'.
%
% CALL:              obj.setArgsmin(<double>);
%              obj = obj.setArgsmin(<double>); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setArgsmin(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~isnumeric(val)
    error('### The value for the property ''argsmin'' must be a double but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'argsmin'
  obj.argsmin = val;

  varargout{1} = obj;
end

