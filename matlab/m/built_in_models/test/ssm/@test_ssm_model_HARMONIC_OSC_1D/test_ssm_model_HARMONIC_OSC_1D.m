% TEST_ssm_MODEL_HARMONIC_OSC_1D runs tests for the ao built-in model HARMONIC_OSC_1D.
%
% VERSION: $Id$
%
classdef test_ssm_model_HARMONIC_OSC_1D < ltpda_builtin_models_ssm_utp & ltpda_builtin_ssm_models_converted_utp 
  
  methods
    function utp = test_ssm_model_HARMONIC_OSC_1D()
      utp = utp@ltpda_builtin_models_ssm_utp();
      utp.className     = 'ssm';
      utp.methodName    = 'HARMONIC_OSC_1D';
      utp.modelFilename = 'ssm_model_HARMONIC_OSC_1D';
    end
  end
  
end
