classdef test_ao_xydata_table < ltpda_xydata_table
  
  methods
    function utp = test_ao_xydata_table(varargin)
      utp = utp@ltpda_xydata_table();
      
      % Only xydata objects
      a = ao(1:12, randn(12,1));
      a.setYunits('Hz');
      a.setXunits('m');
      
      b = ao(1:12, randn(12,1));
      
      utp.testData = [a b];
      
    end
  end
  
end
