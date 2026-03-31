% SORT returns a sorted set of parameters.
%
% CALL
%        params        = sort(params)
%        [params, idx] = sort(params)
%
function varargout = sort(params, varargin)
  
  [~, idx] = sort({params.name}, varargin{:});
  
  varargout{1} = params(idx);
  varargout{2} = idx;
  
end
% END