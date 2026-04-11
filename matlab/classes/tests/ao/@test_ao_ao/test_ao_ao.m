% TEST_AO_AO run tests on the AO constructor and associated methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TEST_AO_AO run tests on the AO constructor and associated methods.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef test_ao_ao < ltpda_uoh_tests

  
  methods
    function utp = test_ao_ao(varargin)
      
      utp.testData = test_ao_ao.generateMixedTestData();
      
      utp.methodName = 'ao';
      utp.className  = 'ao';
      
    end
    
  end
  

  methods (Static, Access=private)
    
    function out = generateMixedTestData()      
      out = [];
      
      % Single number cdata ao
      out = [out ao(1)];
      
      % Time-series ao
      out = [out ao(plist('tsfcn', 't', 'fs', 2.3, 'nsecs', 10))];
      
      % Frequency-series AO
      out = [out ao(plist('fsfcn', 'randn(size(f)).^2', 'f', 1:10))];
        
      % XY AO
      out = [out ao(1:10,1:10)];
    end % End generateTestData()
    
  end % End private methods
  
  
end

% END