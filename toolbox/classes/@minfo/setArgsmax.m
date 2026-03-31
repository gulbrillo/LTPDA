% SETARGSMAX Set the property 'argsmax'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'argsmax'.
%
% CALL:              obj.setArgsmax(<double>);
%              obj = obj.setArgsmax(<double>); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setArgsmax(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~isnumeric(val)
    error('### The value for the property ''argsmax'' must be a double but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'argsmax'
  obj.argsmax = val;

  varargout{1} = obj;
end

