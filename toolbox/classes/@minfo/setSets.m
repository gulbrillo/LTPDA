% SETSETS Sets the property 'sets'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Sets the property 'sets'.
%
% CALL:        obj.setSets(cell-array-of-strings);
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setSets(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  if ~iscellstr(val)
    error('### The value for the property ''sets'' must be a cell array of strings but it is from the class [%s]!', class(val));
  end
  
  %%% Accept only 'modifier' commands
  assert(nargout == 0, 'Please use this setter only as a modifier. (No outputs)');
  
  %%% set 'sets'
  obj.sets = val;
  
  varargout{1} = obj;
end

