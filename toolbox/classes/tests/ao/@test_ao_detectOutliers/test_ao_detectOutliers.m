% TEST_ao_detectOutliers runs tests for the ao method detectOutliers.
%

classdef test_ao_detectOutliers < ltpda_uoh_method_tests
  
  methods
    function utp = test_ao_detectOutliers()
      utp = utp@ltpda_uoh_method_tests();
      utp.className     = 'ao';
      utp.methodName    = 'detectOutliers';
      utp.module        = 'ltpda';
      utp.testData      = ...
        subsData(ao.randn(100),plist(...
        'indices',[10 15; 20 25; 30 35;],...
        'mode','Constant',...
        'value',10));
      utp.configPlist   = plist('threshold',6,'cushion',2);
    end
  end
  
  methods
    function res = test_preserves_plotinfo(varargin)
      % TEST_PRESERVES_PLOTINFO This method doesn't preserves the plotinfo
      res = 'This method doesn''t preserves the plotinfo';
    end
    
  end
  
end
