% TEST_AO_MODEL_SQUAREWAVE runs tests for the AO built-in model
% 'AO_MODEL_SQUAREWAVE'.
%
% VERSION: $Id$
%
classdef test_ao_model_squarewave < ltpda_waveform_signals_utp
  
  methods
    function utp = test_ao_model_squarewave()
      utp = utp@ltpda_waveform_signals_utp();
      utp.className     = 'ao';
      utp.methodName    = 'squarewave';
      utp.modelFilename = 'ao_model_squarewave';
    end
  end
  
end
