% TEST_ao_powerFit runs tests for the ao method powerFit.
%

classdef test_ao_powerFit < ltpda_uoh_method_tests
  
  methods
    function utp = test_ao_powerFit()
      utp = utp@ltpda_uoh_method_tests();
      utp.className     = 'ao';
      utp.methodName    = 'powerFit';
      utp.module        = 'ltpda';
      utp.exceptionList = [utp.exceptionList {'name'}];
      utp.testData      = ao(plist('fsfcn', '1e-6.*f.^0 + 1e-3.*f.^2', 'f', logspace(-4, 0, 100)));
    end
  end
  
end
