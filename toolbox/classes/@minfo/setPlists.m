% SETPLISTS Sets the property 'plists'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the property 'plists'.
%
% CALL:        obj.setPlists(PLIST-object(s));
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPlists(varargin)

  obj = varargin{1};
  val = varargin{2};

  if ~isempty(val) && ~isa(val, 'plist')
    error('### The value for the property ''plists'' must be a PLIST-object but it is from the class [%s]!', class(val));
  end

  %%% Accept only 'modifier' commands
  assert(nargout == 0, 'Please use this setter only as a modifier. (No outputs)');
  
  %%% set 'plists'
  obj.plists = val;

  varargout{1} = obj;
end

