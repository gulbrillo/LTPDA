% OBJECTEQUALSWITHEXCEPTION Assert that two ltpda_obj objects are equal with an exception list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Assert that two ltpda_obj objects are equal with an
%              exception list.
%              objectEquals(A, B) throws an AssertionFailed exception if
%              eq(A,B, exception_list) is not equal. A and B must have the
%              same class and the same length.
%
% COMMAND:     Assert.objectEqualsWithException(val1, val2, exceptions)
%              Assert.objectEqualsWithException(val1, val2, exceptions, message)
%
% EXCEPTIONS:  - a cell array with the exceptions.
%              - a PLIST with the parameter 'Exceptions' for the key and a
%                cell array with exceptions for the value.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectEqualsWithException(val1, val2, ex, varargin)
  
  % Check number in input arguments
  if nargin < 3
    Assert.fail('This function needs at least three inputs.');
  end
  
  % Check class of the input arguments
  if ~strcmp(class(val1), class(val2))
    Assert.fail('The input arguments must be from the same class.');
  end
  
  % Check class of the input arguments
  if ~isa(val1, 'ltpda_obj')
    Assert.fail('The input arguments must be derived from the ltpda_obj class.');
  end
  
  % Check the exception list
  if isa(ex, 'plist') && ex.isparam('Exceptions')
    ex = ex.find('Exceptions');
  elseif iscell(ex)
    % Don't do anything
  else
    Assert.fail('The exception list must be a cell array or a PLIST.');
  end
  
  % Check the length of the inputs
  if numel(val1) ~= numel(val2)
    Assert.fail('The input arguments don''t have the same length.');
  end
  
  if ~eq(val1, val2, ex{:})
    Assert.fail(varargin{:});
  end
  
end
