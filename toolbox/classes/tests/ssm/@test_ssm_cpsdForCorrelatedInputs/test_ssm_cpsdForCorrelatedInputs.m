classdef test_ssm_cpsdForCorrelatedInputs < ltpda_uoh_method_tests
  
  methods    
    function utp = test_ssm_cpsdForCorrelatedInputs()
      utp = utp@ltpda_uoh_method_tests();
      utp.methodName = 'cpsdForCorrelatedInputs';
      utp.className = 'ssm';
      
      % Make a test object
      utp.testData = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
      
      % Make covariance matrix for all inputs
      cov = eye(2); % The model has two inputs      
      % Get port names
      portNames = utp.testData.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));      
      % All outputs
      outputs = utp.testData.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
      
      % Test plist
      utp.configPlist = plist(...
        'COVARIANCE VARIABLE NAMES', portNames, ...
        'COVARIANCE', cov, ...
        'return outputs', outputs, ...
        'f', logspace(-2, 2, 100));
      
    end
  end
  
end