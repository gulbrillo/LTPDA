% TEST_SMODEL_MODEL_SINEWAVE runs tests for the smodel built-in model sinewave.
%
% VERSION: $Id$
%
classdef test_smodel_model_sinewave < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_sinewave()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'sinewave';
      utp.modelFilename = 'smodel_model_sinewave';
    end
  end
  
end
