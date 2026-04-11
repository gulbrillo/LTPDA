% TEST_SMODEL_MODEL_SQUAREWAVE runs tests for the smodel built-in model squarewave.
%
% VERSION: $Id$
%
classdef test_smodel_model_squarewave < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_squarewave()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'squarewave';
      utp.modelFilename = 'smodel_model_squarewave';
    end
  end
  
end
