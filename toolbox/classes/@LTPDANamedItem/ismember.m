% ISMEMBER returns true for set member.
%
% CALL
%        flag = unique(params1, params2)
%        [flag, idx] = unique(params1, params2)
%
function varargout = ismember(A, B, varargin)
  
  [varargout{1:nargout}] = ismember({A.name}, {B.name}, varargin{:});
  
end
% END