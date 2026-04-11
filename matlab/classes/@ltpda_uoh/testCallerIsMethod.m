% TESTCALLERISMETHOD hidden static method which tests the 'internal' command of a LTPDA-function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TESTCALLERISMETHOD hidden static method which tests the 'internal'
%              command of a LTPDA-function. This means for example that the
%              method doesn't add history to the object.
%
% CALL:        'normal' command
%                 out = ltpda_uoh.testCallerIsMethod(@fcn, arg1, arg2, ...);
%
%              modifier command
%                 ltpda_uoh.testCallerIsMethod(@fcn, arg1, arg2, ...);
%
% INPUTS:      fcn:  Function name you want to test
%              args: Input arguments for the function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = testCallerIsMethod(varargin)
  
  fcn = varargin{1};
  args = varargin(2:end);
  
  if nargout >= 1
    out = fcn(args{:});
  else
    fcn(args{:});
    out = args{1};
  end
  
end
