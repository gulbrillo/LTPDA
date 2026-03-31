% SETOUTMIN Set the property 'outmin'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'outmin'.
%
% CALL:              obj.setOutmin(<double>);
%              obj = obj.setOutmin(<double>); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOutmin(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~isnumeric(val)
    error('### The value for the property ''outmin'' must be a double but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'outmin'
  obj.outmin = val;

  varargout{1} = obj;
end

