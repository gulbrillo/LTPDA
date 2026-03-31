% TEST_ao_MODEL_padded_sine runs tests for the ao built-in model padded_sine.
%
% VERSION: $Id$
%
classdef test_ao_model_padded_sine < ltpda_builtin_model_utp
  
  methods
    function utp = test_ao_model_padded_sine()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'ao';
      utp.methodName    = 'padded_sine';
      utp.modelFilename = 'ao_model_padded_sine';
    end
  end
  
end
