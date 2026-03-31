% OBJECTEQUALS Assert that two ltpda_obj objects are equal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that two ltpda_obj objects are equal.
%              objectEquals(A, B) throws an AssertionFailed exception if A
%              and B are not equal. A and B must have the same class and
%              the same length.
%
% COMMAND:     Assert.objectEquals(val1, val2)
%              Assert.objectEquals(val1, val2, message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectEquals(val1, val2, varargin)
  
  % Check class of the input arguments
  if ~strcmp(class(val1), class(val2))
    Assert.fail('The input arguments must be from the same class.');
  end
  
  % Check class of the input arguments
  if ~isa(val1, 'ltpda_obj')
    Assert.fail('The input arguments must be derived from the ltpda_obj class.');
  end
  
  % Check the length of the inputs
  if numel(val1) ~= numel(val2)
    Assert.fail('The input arguments don''t have the same length.');
  end
  
  if ~eq(val1, val2)
    Assert.fail(varargin{:});
  end
  
end
