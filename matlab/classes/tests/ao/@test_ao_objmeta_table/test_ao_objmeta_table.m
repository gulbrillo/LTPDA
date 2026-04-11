classdef test_ao_objmeta_table < ltpda_objmeta_table
  
  methods
    function utp = test_ao_objmeta_table(varargin)
      utp = utp@ltpda_objmeta_table();
      
      % cdata
      a = ao(8);
      a.setName('My test: objmeta');
      
      % xydata
      b = ao(1:12, randn(12,1));
      b.setName('My test: objmeta');
      
      % tsdata
      c = ao(1:12, randn(12,1), 1);
      c.setName('My test: objmeta');
      
      % fsdata
      d = ao(1:12, randn(12,1), plist('type', 'fsdata'));
      d.setName('My test: objmeta');
      
      utp.testData = [a b c d];
      
      
    end
  end
  
end
