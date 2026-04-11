% FAIL throws an AssertionFailed exception with the given message.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FAIL throws an AssertionFailed exception with the given message.
%
% COMMAND:     Assert.fail(message)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fail(varargin)
  
  if isempty(varargin)
    ex = AssertionFailed(Assert.errMsgId, Assert.defaultErrMsg);
  else
    ex = AssertionFailed(Assert.errMsgId, varargin{:});
  end
  
  ex.throwAsCaller();
  
end
