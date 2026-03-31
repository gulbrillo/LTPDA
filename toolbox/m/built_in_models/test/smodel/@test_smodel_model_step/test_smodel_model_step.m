% TEST_SMODEL_MODEL_STEP runs tests for the smodel built-in model step.
%
% VERSION: $Id$
%
classdef test_smodel_model_step < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_step()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'step';
      utp.modelFilename = 'smodel_model_step';
    end
  end
  
end
