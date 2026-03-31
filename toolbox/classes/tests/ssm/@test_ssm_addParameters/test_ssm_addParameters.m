classdef test_ssm_addParameters < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_addParameters()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'addParameters';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
      
      % Test config plist
      utp.configPlist = plist('a', 1);
      
    end
  end
  
end