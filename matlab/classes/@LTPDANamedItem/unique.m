% UNIQUE returns a set of parameters where non have the same name.
%
% CALL
%        params = unique(params)
%
function [params, idxIn, idxOut] = unique(params, varargin)
  
  try
    if nargin > 1
      [~, idxIn, idxOut] = unique({params.name}, varargin{:});
    else
      % try to avoid sorting
      [~, idxIn, idxOut] = unique({params.name}, 'stable');
    end
  catch
    % the 'stable' option is not supported before 2012a
    [~, idxIn, idxOut] = unique({params.name});
  end
  
  params = params(idxIn);
  
end
% END