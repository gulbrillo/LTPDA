% A list of tests for running and installing in the toolbox as examples.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: A list of tests for running and installing
%              in the toolbox as examples.
%
% CALL:             test_list
%
% GLOBAL VARIABLES: tests_def             fild with the test definitions
%
%                   test_struct.name      structure Structure with contents
%                   test_struct.example   of the field tests_def
%
% VERSION: $Id$
%
% HISTORY: 07-05-2007 Diepholz
%             Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tests_def = {'ao_class_test'            1; ...   %   1
             'example_1'                1; ...   %   2
             'example_2'                1; ...   %   3
             'test_abs'                 1; ...   %   7
             'test_ao_1'                1; ...   %   8
             'test_ao_split'            1; ...   %   9
             'test_ao_tsfcn'            1; ...   %  10
             'test_conj'                1; ...   %  12
             'test_ctranspose'          1; ...   %  13
             'test_det'                 1; ...   %  14
             'test_diag'                1; ...   %  15
             'test_eig'                 1; ...   %  16
             'test_fft'                 1; ...   %  17
             'test_iir_filtering'       1; ...   %  18
             'test_inv'                 1; ...   %  19
             'test_lincom_cdata'        1; ...   %  20
             'test_lpsd'                1; ...   %  21
             'test_ltpda_cohere'        1; ...   %  22
             'test_ltpda_cpsd'          1; ...   %  23
             'test_ltpda_lincom'        1; ...   %  24
             'test_ltpda_polydetrend'   1; ...   %  25
             'test_ltpda_pwelch'        1; ...   %  26
             'test_ltpda_tfe'           1; ...   %  27
             'test_mean'                1; ...   %  28
             'test_miir_class'          1; ...   %  29
             'test_miir_filter'         1; ...   %  30
             'test_miir_filtfilt'       1; ...   %  31
             'test_miir_redesign'       1; ...   %  32
             'test_norm'                1; ...   %  33
             'test_plist_string'        1; ...   %  34
             'test_minus'               1; ...   %  35
             'test_mpower'              1; ...   %  36
             'test_times'               1; ...   %  37
             'test_rdivide'             1; ...   %  38
             'test_plus'                1; ...   %  39
             'test_pzmodel_class'       1; ...   %  40
             'test_recreate_1'          1; ...   %  41
             'test_resample'            1; ...   %  42
             'test_simulated_data'      1; ...   %  43
             'test_svd'                 1; ...   %  44
             'test_transpose'           1; ...   %  45
             'test_xml_complex'         1; ...   %  46
             'testing_xml'              1; ...   %  47
             'test_fir_filter'          1; ...   %  50
             'test_mfir_class'          1; ...   %  51
             'test_ao_split_frequency'  1; ...   %  52
             'test_ao_downsample'       1; ...   %  53
             'test_ao_find'             1; ...   %  54
             'test_ao_select'           1; ...   %  55
             'test_ltpda_linedetect'    1; ...   %  56
             'test_ltpda_nfest'         1; ...   %  57
             'test_ao_waveform'         1; ...   %  58
             'test_filter_edges'        1; ...   %  60
             'test_ltpda_ltfe'          1; ...   %  61
             'test_sin'                 1; ...   %  62
             'test_asin'                1; ...   %  63
             'test_cos'                 1; ...   %  64
             'test_acos'                1; ...   %  65
             'test_tan'                 1; ...   %  66
             'test_atan'                1; ...   %  67
             'test_ao_hist'             1; ...   %  68
             'test_log_ln'              1; ...   %  69
             'test_log10'               1; ...   %  70
             'test_exp'                 1; ...   %  71
             'test_sqrt'                1; ...   %  72
             'test_median'              1; ...   %  73
             'test_std'                 1; ...   %  74
             'test_var'                 1; ...   %  75
             'test_ao_join_ts'          1; ...   %  76
             'test_ao_polyfit'          1; ...   %  77
             'test_ao_interp'           1; ...   %  78
             'test_ltpda_xcorr'         1; ...   %  79
             'test_pzm_to_fir'          1; ...   %  80
             'test_ao_spikecleaning'    1; ...   %  81
             'test_ao_gapfilling'       1; ...   %  82
             'test_ao_freq_series'      1; ...   %  84
             'test_ao_upsample'         1; ...   %  85
             'test_iplot'               1; ...   %  87
             'test_iplot_2'             1; ...   %  88
             'test_ao_pwelch'           1; ...   %  89
             'test_ao_tfe'              1; ...   %  90
             'test_ao_cohere'           1; ...   %  91
             'test_ao_cpsd'             1; ...   %  92
             'test_ao_cov'              1; ...   %  94
             'test_ao_fromVals'         1; ...   %  95
             'test_ao_lincom'           1; ...   %  96
             'test_ao_xfit'             1; ...   %  97
             'test_ao_bilinfit'         1; ...   %  98
             'test_ao_linedetect'       1; ...   %  99
             'test_ao_heterodyne'       1; ...   % 100
             'test_ao_linfit'           1; ...   % 101
             'test_ao_lscov'            1; ...   % 102
             'test_ao_rotate'           1; ...   % 103
             'test_ao_timeaverage'      1; ...   % 104
             'test_LTPDAprefs_cl_set'   1; ...   % 105
             'test_smodel_double'       1; ...   % 106
             'test_smodel_eval'         1; ...   % 107
             'test_ao_fftfilt'          1; ...   % 108
             'test_ao_removeVal'        1; ...   % 109
             'test_ao_consolidate'      1; ...   % 110
             'test_tsdata_class'        1; ...   % 111
             'test_ao_plot'             1; ...   % 112
             'test_collection_history'  1; ...   % 113
             'test_collection_plot'     1; ...   % 114
             'test_matrix_plot'         1; ...   % 115
             'test_isequal'             1; ...   % 116
             'test_iplot_3'             1; ...   % 117
             'test_ao_detrend'          1; ...   % 118
             };

test_struct = [];

for jj = 1:length(tests_def)
  test_struct(jj).name    = tests_def{jj,1};
  test_struct(jj).example = tests_def{jj,2};
end


%  END
