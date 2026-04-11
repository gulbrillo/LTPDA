% TEST_AO_MODEL_SINEWAVE runs tests for the AO built-in model
% 'AO_MODEL_SINEWAVE'.
%
% VERSION: $Id$
%
classdef test_ao_model_sinewave < ltpda_waveform_signals_utp
  
  methods
    function utp = test_ao_model_sinewave()
      utp = utp@ltpda_waveform_signals_utp();
      utp.className     = 'ao';
      utp.methodName    = 'sinewave';
      utp.modelFilename = 'ao_model_sinewave';
    end
  end
  
end
