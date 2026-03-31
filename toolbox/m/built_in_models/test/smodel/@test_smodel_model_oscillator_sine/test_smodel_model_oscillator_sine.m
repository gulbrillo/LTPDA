% TEST_SMODEL_MODEL_OSCILLATOR_SINE runs tests for the smodel built-in model oscillator_sine.
%
% VERSION: $Id$
%
classdef test_smodel_model_oscillator_sine < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_oscillator_sine()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'oscillator_sine';
      utp.modelFilename = 'smodel_model_oscillator_sine';
    end
  end
  
end
