% ADDSUPPORTEDNUMTYPES Add a value to the property 'supportedNumTypes'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Add a value to the property 'supportedNumTypes'.
%
% CALL:        obj.addSupportedNumTypes('double')
%              obj.addSupportedNumTypes('double', 'single')
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addSupportedNumTypes(varargin)

  obj = varargin{1};
  val = varargin(2:end);

  if ~iscellstr(val)
    error('### The value for the property ''supportedNumTypes'' must be a cell of strings but it is from the class [%s]!', class(val));
  end

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% add 'supportedNumTypes'
  obj.supportedNumTypes = [obj.supportedNumTypes val];

  varargout{1} = obj;
end

