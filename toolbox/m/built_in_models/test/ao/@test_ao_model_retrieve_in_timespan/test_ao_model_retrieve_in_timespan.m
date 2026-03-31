% TEST_ao_MODEL_retrieve_in_timespan runs tests for the ao built-in model retrieve_in_timespan.
%
% VERSION: $Id$
%
classdef test_ao_model_retrieve_in_timespan < ltpda_builtin_model_utp
  
  methods
    function utp = test_ao_model_retrieve_in_timespan()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'ao';
      utp.methodName    = 'retrieve_in_timespan';
      utp.modelFilename = 'ao_model_retrieve_in_timespan';
    end
  end
  
end
