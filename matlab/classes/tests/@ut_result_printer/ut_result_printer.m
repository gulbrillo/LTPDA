% UT_RESULT_PRINTER displays results from an ltpda_test_runner.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   UT_RESULT_PRINTER provides methods to view the result-set
% contained in an ltpda_test_runner.
% 
% CALL:
%        printer = ut_result_printer(ltpda_test_runner)
% 
% SUPER CLASSES: handle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ut_result_printer
  
  properties
    results = [];
  end
  
  properties (Dependent = true)
    npassed;
    nresults;
  end
  
  methods
    
    function val = get.npassed(urp)
      if isempty(urp.results)
        val = 0;
      else
        val = sum([urp.results(:).passed]);
      end
    end
    
    function val = get.nresults(urp)
      val = numel(urp.results);
    end
    
    function urp = ut_result_printer(runner)
      urp.results = runner.results;
    end
        
    
    
  end
  
  methods (Access=private)
    
    
  end
  
  
  
  methods (Static)
    
    function str = dispRuntime(res)
      if numel(res.testMethod) > 35
        res.testMethod = [fcn(1:31), ' ...'];
      end
      str = sprintf('%-36s  %8.3f s\n', res.testMethod, res.runtime);
    end
    
    function str = dispRes(res)
      if numel(res.testMethod) > 35
        res.testMethod = [fcn(1:31), ' ...'];
      end
      str = sprintf('%-36s%s  %s %s %s\n', res.testMethod, ut_result_printer.res2str(res.syntax), ut_result_printer.res2str(res.algorithm), ut_result_printer.res2str(res.skipped), res.message);
    end
    
    function str = res2str(a)
      if islogical(a)
        if (a)
          str = '  pass  ';
        else
          str = '--fail--';
        end
      elseif ischar(a)
        str = a;
      else
        str = '';
      end
    end
    
  end
  
  
end
