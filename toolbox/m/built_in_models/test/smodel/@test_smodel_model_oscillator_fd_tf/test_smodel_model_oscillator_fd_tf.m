% TEST_SMODEL_MODEL_OSCILLATOR_FD_TF runs tests for the smodel built-in model oscillator_fd_tf.
%
% VERSION: $Id$
%
classdef test_smodel_model_oscillator_fd_tf < ltpda_builtin_model_utp
  
  methods
    function utp = test_smodel_model_oscillator_fd_tf()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'smodel';
      utp.methodName    = 'oscillator_fd_tf';
      utp.modelFilename = 'smodel_model_oscillator_fd_tf';
    end
  end
  
end
