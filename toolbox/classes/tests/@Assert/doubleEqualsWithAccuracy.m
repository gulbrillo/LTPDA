% DOUBLEEQUALSWITHACCURACY Assert that two doubles are equal within some tolerance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that two doubles are equal within some tolerance.
%              doubleEqualsWithAccuracy(A, B, tol) throws an
%              AssertionFailed exception if A and B are not equal within a
%              tolerance.
%              A and B must have the same class and the same length.
%
% COMMAND:     Assert.doubleEquals(val1, val2, tol)
%              Assert.doubleEquals(val1, val2, tol, message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doubleEqualsWithAccuracy(val1, val2, tol, varargin)
  
  % Check class of the input arguments
  if ~isnumeric(val1) || ~isnumeric(val2)
    Assert.fail('The input arguments must be two double.');
  end
  
  % Check the length of the inputs
  if numel(val1) ~= numel(val2)
    Assert.fail('The input arguments don''t have the same length.');
  end
  
  if abs(val1 - val2) > tol
    Assert.fail(varargin{:});
  end
  
end
