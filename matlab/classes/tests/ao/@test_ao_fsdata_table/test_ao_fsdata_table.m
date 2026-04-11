classdef test_ao_fsdata_table < ltpda_fsdata_table
  
  methods
    function utp = test_ao_fsdata_table(varargin)
      utp = utp@ltpda_fsdata_table();
      
      % Only fsdata objects
      a = ao(1:12, randn(12,1), plist('type', 'fsdata'));
      a.setYunits('Hz');
      a.setXunits('m');
      a.setFs(8);
      
      b = ao(1:12, randn(12,1), plist('type', 'fsdata'));
      
      utp.testData = [a b];
      
    end
  end
  
end
