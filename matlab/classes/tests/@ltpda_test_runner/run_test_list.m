% GET_CLASS_TESTS runs all the tests specified in the array of test structures.
% 
% CALL: 
%       runner.run_test_list(list)
% 
% 
%    list - The array of input test structures of the form:
% 
%       test.utp     % instance of the unit test class
%       test.methods % a cell-array of the methods to be run
% 

function run_test_list(runner, list)
  
  for kk=1:numel(list)
    
    t = list(kk);
    
    for ll=1:numel(t.methods)
      mth = t.methods{ll};
      try
        disp(['* running ' class(t.utp) '/' mth ' ...'])
        result = ut_result(t.utp,mth);
        res = t.utp.(mth)(runner);
        result.finish();
        result.message = res;
        result.passed = true;
        runner.appendResult(result);
%         fprintf('\b pass\n');
      catch Me
        runner.appendErrorResult(t.utp, mth, Me);
        fprintf(2,'%s\n', Me.getReport());
      end
      
    end
    
  end
  
end
