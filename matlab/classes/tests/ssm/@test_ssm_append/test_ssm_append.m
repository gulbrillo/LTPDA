classdef test_ssm_append < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_append()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'append';
      utp.className = 'ssm';
      
      % Make an array of test objects
      utp.testData = [ssm(plist('built-in', 'HARMONIC_OSC_1D')) ssm(plist('built-in', 'HARMONIC_OSC_1D'))];

      % Test plist
      utp.configPlist = plist();
      
    end
  end
  
end