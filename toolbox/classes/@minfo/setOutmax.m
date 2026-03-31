% SETOUTMAX Set the property 'outmax'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'outmax'.
%
% CALL:              obj.setOutmax(<double>);
%              obj = obj.setOutmax(<double>); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOutmax(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~isnumeric(val)
    error('### The value for the property ''outmax'' must be a double but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'outmax'
  obj.outmax = val;

  varargout{1} = obj;
end

