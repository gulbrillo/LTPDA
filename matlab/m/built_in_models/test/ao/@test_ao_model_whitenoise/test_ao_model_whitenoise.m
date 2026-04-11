% TEST_AO_MODEL_WHITENOISE runs tests for the AO built-in model
% 'AO_MODEL_WHITENOISE'.
%
% VERSION: $Id$
%
classdef test_ao_model_whitenoise < ltpda_waveform_signals_utp
  
  methods
    function utp = test_ao_model_whitenoise()
      utp = utp@ltpda_waveform_signals_utp();
      utp.className     = 'ao';
      utp.methodName    = 'whitenoise';
      utp.modelFilename = 'ao_model_whitenoise';
    end
  end
  
end
