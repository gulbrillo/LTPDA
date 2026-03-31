classdef test_ssm_assemble < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_assemble()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'assemble';
      utp.className = 'ssm';
      
      % Make an array of test objects
      utp.testData = [ssm(plist('built-in', 'HARMONIC_OSC_1D')) ssm(plist('built-in', 'HARMONIC_OSC_1D'))];

      % Test plist
      utp.configPlist = plist();
      
    end
  end
  
end