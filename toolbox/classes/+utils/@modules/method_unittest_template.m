% TEST_<CLASS>_<METHOD> runs tests for the <CLASS> method <METHOD>.
%

classdef test_<CLASS>_<METHOD> < ltpda_uoh_method_tests
  
  methods
    function utp = test_<CLASS>_<METHOD>()
      utp = utp@ltpda_uoh_method_tests();
      utp.className     = '<CLASS>';
      utp.methodName    = '<METHOD>';
      utp.module        = '<MODULE>';
      utp.testData      = eval(utp.className);
    end
  end
  
end
