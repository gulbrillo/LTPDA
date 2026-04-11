% ISEQUAL test if two matrices are equal to within the given tolerance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL test if two matrices are equal to within the given
%              tolerance.
%
% CALL:       result = isequal(m1, m2)
%             result = isequal(m1, m2, tol)
%
% INPUTS:     m1  - a matrix of real or complex values
%             m2  - a matrix of real or complex values
%             tol - the tolerance to test against [default: 1e-14]
%
% OUTPUTS:    result - true or false
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = isequal(varargin)
  
  % Check size of the input numbers
  if  ~all(size(varargin{1}) == size(varargin{2}))        || ...
      ~(isnumeric(varargin{1}) || islogical(varargin{1})) || ...
      ~(isnumeric(varargin{2}) || islogical(varargin{2}))
    res = false;
    return
  end
  
  m1 = double(varargin{1});
  m2 = double(varargin{2});
  
  
  if nargin > 2 && ~isempty(varargin{3})
    tol = varargin{3};
  else
    tol = 1e-14;
  end  
  
  if  norm(m2-m1, Inf) <= tol
    res = true;
  else
    res = false;
  end
  
end
