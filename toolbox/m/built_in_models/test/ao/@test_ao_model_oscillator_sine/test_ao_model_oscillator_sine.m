% TEST_ao_MODEL_oscillator_sine runs tests for the ao built-in model oscillator_sine.
%
% VERSION: $Id$
%
classdef test_ao_model_oscillator_sine < ltpda_builtin_model_utp
  
  methods
    function utp = test_ao_model_oscillator_sine()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'ao';
      utp.methodName    = 'oscillator_sine';
      utp.modelFilename = 'ao_model_oscillator_sine';
    end
  end
  
end
