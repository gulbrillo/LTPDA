classdef test_ssm_reorganize < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_reorganize()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'reorganize';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D'));

      % Config plist
      utp.configPlist = plist('set', 'For bode');
      
    end
  end
  
end