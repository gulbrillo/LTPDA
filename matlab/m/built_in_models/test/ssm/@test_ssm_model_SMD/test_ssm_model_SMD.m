% TEST_ssm_MODEL_SMD runs tests for the ao built-in model SMD.
%
% VERSION: $Id$
%
classdef test_ssm_model_SMD < ltpda_builtin_models_ssm_utp & ltpda_builtin_ssm_models_converted_utp 
  
  methods
    function utp = test_ssm_model_SMD()
      utp = utp@ltpda_builtin_models_ssm_utp();
      utp.className     = 'ssm';
      utp.methodName    = 'SMD';
      utp.modelFilename = 'ssm_model_SMD';
    end
  end
  
end
