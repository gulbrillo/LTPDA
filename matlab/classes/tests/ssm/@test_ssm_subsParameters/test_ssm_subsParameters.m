classdef test_ssm_subsParameters < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_subsParameters()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'subsParameters';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D', ...
        'symbolic params', {'M', 'K', 'VBETA'}));

      % Config plist
      utp.configPlist = plist('names', 'all');
      
    end
  end
  
end