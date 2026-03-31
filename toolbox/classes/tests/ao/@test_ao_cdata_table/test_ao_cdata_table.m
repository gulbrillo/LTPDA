classdef test_ao_cdata_table < ltpda_cdata_table
  
  methods
    function utp = test_ao_cdata_table(varargin)
      utp = utp@ltpda_cdata_table();
      
      % Only cdata objects
      a = ao(8);
      a.setYunits('Hz');
      
      b = ao(magic(3));
      b.setYunits('Hz^2 m^-1/3');
      
      c = ao(1:12);
      
      utp.testData = [a b c];
      
    end
  end
  
end
