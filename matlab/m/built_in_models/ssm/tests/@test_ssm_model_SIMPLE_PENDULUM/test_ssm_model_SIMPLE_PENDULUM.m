% TEST_SSM_MODEL_SIMPLE_PENDULUM runs tests for the ssm built-in model 'SIMPLE_PENDULUM'.
%
%
classdef test_ssm_model_SIMPLE_PENDULUM < ltpda_builtin_models_ssm_utp & ltpda_builtin_ssm_models_converted_utp
  
  methods
    function utp = test_ssm_model_SIMPLE_PENDULUM()
      utp = utp@ltpda_builtin_models_ssm_utp();
      utp.className     = 'ssm';
      utp.methodName    = 'SIMPLE_PENDULUM';
      utp.modelFilename = 'ssm_model_SIMPLE_PENDULUM';
    end
  end
  
end
