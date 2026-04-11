classdef test_ao_tsdata_table < ltpda_tsdata_table
  
  methods
    function utp = test_ao_tsdata_table(varargin)
      utp = utp@ltpda_tsdata_table();
      
      % Only tsdata objects
      
      % Time object with milli seconds
      a = ao(1:12, randn(12,1), 1);
      
      a1 = a.setT0('2011-01-01 14:14:14.123');
      a2 = a.setT0('2011-01-01 14:14:14.001');
      a3 = a.setT0('2011-01-01 14:14:14.499');
      a4 = a.setT0('2011-01-01 14:14:14.5');
      a5 = a.setT0('2011-01-01 14:14:14.501');
      a6 = a.setT0('2011-01-01 14:14:14.999');

      % Use a time in a different timezone.
      b = ao(1:12, randn(12,1), 1);
      b.setYunits('Hz');
      b.setXunits('m');
      t0 = time();
      b.setT0(time.now/1e3);
      
      % Set the toffset
      c = ao(12:42, randn(31,1), 1);
      c.setToffset(123.3333);
 
      c1 = c.setT0('2011-01-01 14:14:14.170'); % t0 + toffset = xxx.5
      c2 = c.setT0('2011-01-01 14:14:14.171'); % t0 + toffset = xxx.501
      c3 = c.setT0('2011-01-01 14:14:14.169'); % t0 + toffset = xxx.499
      c4 = c.setT0('2011-01-01 14:14:14.671'); % t0 + toffset = xxx.001
      c5 = c.setT0('2011-01-01 14:14:14.669'); % t0 + toffset = xxx.999
      
      utp.testData = [a1, a2, a3, a4, a5, a6, b, c1, c2, c3, c4, c5];
      
    end
  end
  
end
