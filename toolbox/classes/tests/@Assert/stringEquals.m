% STRINGEQUALS Assert that two strings are equal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that two strings are equal.
%              stringEquals(A, B) throws an AssertionFailed exception if A
%              and B are not equal. A and B must have the same class.
%
% COMMAND:     Assert.stringEquals(val1, val2)
%              Assert.stringEquals(val1, val2, message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stringEquals(val1, val2, varargin)
  
  % Check class of the input arguments
  if ~ischar(val1) || ~ischar(val2)
    Assert.fail('The input arguments must be two string.');
  end
  
  if ~strcmp(val1, val2)
    Assert.fail(varargin{:});
  end
  
end
