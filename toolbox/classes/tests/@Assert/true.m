% TRUE Assert that a condition is true.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that a condition is true.
%              true(A, B) throws an AssertionFailed exception if A is not
%              true.
%
% COMMAND:     Assert.true(condition)
%              Assert.true(condition, message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function true(val, varargin)
  
  % Check class of the input argument
  if ~islogical(val)
    Assert.fail('The condition input arguments must be two double.');
  end
  
  % Check condition
  if ~val
    Assert.fail(varargin{:});
  end
  
end
