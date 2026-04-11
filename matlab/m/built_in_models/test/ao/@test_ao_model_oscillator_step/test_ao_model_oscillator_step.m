% TEST_ao_MODEL_oscillator_step runs tests for the ao built-in model oscillator_step.
%
% VERSION: $Id$
%
classdef test_ao_model_oscillator_step < ltpda_builtin_model_utp
  
  methods
    function utp = test_ao_model_oscillator_step()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'ao';
      utp.methodName    = 'oscillator_step';
      utp.modelFilename = 'ao_model_oscillator_step';
    end
  end
  
end
