% SETMODIFIER Set the property 'modifier'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'modifier'.
%
% CALL:              obj.setModifier(true|false);
%              obj = obj.setModifier(true|false); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setModifier(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~islogical(val)
    error('### The value for the property ''modifier'' must be a logical but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'modifier'
  obj.modifier = val;

  varargout{1} = obj;
end

