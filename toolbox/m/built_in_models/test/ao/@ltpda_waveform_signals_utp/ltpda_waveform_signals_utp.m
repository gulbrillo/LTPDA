% LTPDA_WAVEFORM_SIGNALS_UTP extends the converted built-in
% model utp class to include specific configuration for building the signals.
classdef ltpda_waveform_signals_utp < ltpda_builtin_models_ao_utp & ltpda_uo_tests
  methods
    function utp = ltpda_waveform_signals_utp(varargin)
      utp = utp@ltpda_builtin_models_ao_utp();
      utp.configPlist = plist('nsecs', 100, 'fs', 1);
    end
  end
end
