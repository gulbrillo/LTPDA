% TEST_AO_MODEL_STEP runs tests for the AO built-in model
% 'AO_MODEL_STEP'.
%
% VERSION: $Id$
%
classdef test_ao_model_step < ltpda_waveform_signals_utp
  
  methods
    function utp = test_ao_model_step()
      utp = utp@ltpda_waveform_signals_utp();
      utp.className     = 'ao';
      utp.methodName    = 'step';
      utp.modelFilename = 'ao_model_step';
    end
  end
  
end
