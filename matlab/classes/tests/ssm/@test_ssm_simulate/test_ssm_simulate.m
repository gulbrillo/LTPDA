classdef test_ssm_simulate < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_simulate()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'simulate';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = modifyTimeStep(ssm(plist('built-in', 'HARMONIC_OSC_1D')), 1);

      % Config plist
      a = ao.randn(10,10);
      utp.configPlist = plist('AOS VARIABLE NAMES', 'COMMAND.force', ...
        'AOS', a, ...
        'return outputs', 'HARMONIC_OSC_1D.position', ...
        'nsamples', 1000);
      
    end
  end
  
end