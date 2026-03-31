classdef test_ao_ao_table < ltpda_ao_table
  
  methods
    function utp = test_ao_ao_table(varargin)
      utp = utp@ltpda_ao_table();
      
      % cdata
      a = ao(8);
      a.setName('My test: objmeta');
      a.setDescription('My Description');
      
      % xydata
      b = ao(1:12, randn(12,1));
      b.setName('My test: objmeta');
      b.setDescription('My Description');
      
      % tsdata
      c = ao(1:12, randn(12,1), 1);
      c.setName('My test: objmeta');
      c.setDescription('My Description');
      
      % fsdata
      d = ao(1:12, randn(12,1), plist('type', 'fsdata'));
      d.setName('My test: objmeta');
      d.setDescription('My Description');
      
      utp.testData = [a b c d];
      
      
    end
  end
  
end
