classdef test_ssm_bode < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_bode()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'bode';
      utp.className = 'ssm';
      
      % Make an array of test objects
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D'));

      % Test plist
      utp.configPlist = plist('f', logspace(-2, 2, 100));
      
    end
  end
  
end