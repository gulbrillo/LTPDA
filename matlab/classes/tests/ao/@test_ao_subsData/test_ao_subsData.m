% TEST_ao_subsData runs tests for the ao method subsData.
%

classdef test_ao_subsData < ltpda_uoh_method_tests
  
  methods
    function utp = test_ao_subsData()
      utp = utp@ltpda_uoh_method_tests();
      utp.className     = 'ao';
      utp.methodName    = 'subsData';
      utp.module        = 'ltpda';
      utp.testData      = ao.randn(100);
      utp.configPlist   = plist('indices',[10 15; 20 25; 30 35;],'mode','Constant','value',0);
    end
  end
  
end
