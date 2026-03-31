% TEST_SMODEL_MODEL_OSCILLATOR_STEP runs tests for the smodel built-in model oscillator_step.
%
% VERSION: $Id$
%
classdef test_smodel_model_oscillator_step < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_oscillator_step()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'oscillator_step';
      utp.modelFilename = 'smodel_model_oscillator_step';
    end
  end
  
end
