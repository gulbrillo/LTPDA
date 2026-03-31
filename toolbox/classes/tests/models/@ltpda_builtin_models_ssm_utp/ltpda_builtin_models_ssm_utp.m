% LTPDA_BUILTIN_MODELS_SSM_UTP general UTP for ssm models.
classdef ltpda_builtin_models_ssm_utp < ltpda_builtin_model_utp
  
  methods
    function utp = ltpda_builtin_models_ssm_utp()
      utp = utp@ltpda_builtin_model_utp();
      utp.className     = 'ssm';
      utp.methodName    = '';
      utp.modelFilename = '';
    end
  end
  
end
