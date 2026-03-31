classdef test_ssm_psd < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_psd()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'psd';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
      
      % Get port names
      portNames = utp.testData.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));      
      % All outputs
      outputs = utp.testData.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
      
      % Test plist
      utp.configPlist = plist(...
        'VARIANCE VARIABLE NAMES', portNames, ...
        'VARIANCE', [1 1], ...
        'return outputs', outputs, ...
        'f', logspace(-2, 2, 100));
      
    end
  end
  
end