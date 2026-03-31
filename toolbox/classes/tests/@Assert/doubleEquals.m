% DOUBLEEQUALS Assert that two doubles are equal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that two doubles are equal.
%              doubleEquals(A, B) throws an AssertionFailed exception if A
%              and B are not equal. A and B must have the same class and
%              the same length.
%
% COMMAND:     Assert.doubleEquals(val1, val2)
%              Assert.doubleEquals(val1, val2, message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function doubleEquals(val1, val2, varargin)
  
  % Check class of the input arguments
  if ~isnumeric(val1) || ~isnumeric(val2)
    Assert.fail('The input arguments must be two double.');
  end
  
  % Check the length of the inputs
  if numel(val1) ~= numel(val2)
    Assert.fail('The input arguments don''t have the same length.');
  end
  
  if (val1 ~= val2)
    Assert.fail(varargin{:});
  end
  
end
