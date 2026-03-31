% SETSUPPORTEDNUMTYPES Set the property 'supportedNumTypes'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'supportedNumTypes'.
%
% CALL:        obj.setSupportedNumTypes('double')
%              obj.setSupportedNumTypes('double', 'single')
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setSupportedNumTypes(varargin)

  obj = varargin{1};
  val = varargin(2:end);

  if ~iscellstr(val)
    error('### The value for the property ''supportedNumTypes'' must be a cell of strings but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'supportedNumTypes'
  obj.supportedNumTypes = val;

  varargout{1} = obj;
end

