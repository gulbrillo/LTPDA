% UT_RESULT encapsulates the result of running a single ltpda unit test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   UT_RESULT encapsulates the result of running a single
% ltpda unit test.
%
% SUPER CLASSES: handle
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ut_result < handle
  
  properties
    
    message   = '';
    started   = 0;
    stopped   = 0;
    
    testClass       = '';
    testMethod      = '';
    testDescription = '';
    
    passed = false;
    
  end
  
  properties (Dependent = true)
    runtime;
  end
  
  
  methods
    function result = ut_result(utp, method)
      result.started         = now;
      result.testMethod      = method;
      % Special case if 'utp' is a string
      if ischar(utp)
        result.testClass = utp;
        result.testDescription = 'not available';
      else
        result.testClass = class(utp);
        result.testDescription = feval('help', [class(utp) '/' method]);
      end
    end
    
    function finish(result)
      result.stopped = now;
    end
    
    function val = get.runtime(result)
      val = 86400*(result.stopped - result.started);
    end
    
  end
  
  methods (Static)
    
    function str = formatException(Me)
      str = [strrep(Me.message, sprintf('\n'), ' ') ' - ' Me.stack(1).name ' - line ' num2str(Me.stack(1).line)];
    end
    
  end
  
end