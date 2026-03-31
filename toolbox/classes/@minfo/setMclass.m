% SETMCLASS Set the property 'mclass'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'mclass'.
%
% CALL:              obj.setMclass('string');
%              obj = obj.setMclass('string');
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setMclass(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~ischar(val)
    error('### The value for the property ''mclass'' must be a string but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'mclass'
  obj.mclass = val;

  varargout{1} = obj;
end

