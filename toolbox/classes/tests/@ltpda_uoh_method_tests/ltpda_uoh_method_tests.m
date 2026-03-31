% LTPDA_UOH_METHOD_TESTS a series of tests for methods of ltpda_uoh
% subclasses.
% 
% Some test methods should be overridden to provide sufficient information
% for the test.
% 
classdef ltpda_uoh_method_tests < ltpda_utp
  
  properties
    module = 'ltpda';
    expectedSets   = {};
    expectedPlists = [];
    exceptionList = [];
  end
  
  methods
    function utp = ltpda_uoh_method_tests()
      utp = utp@ltpda_utp();
      utp.configPlist = plist();
      utp.exceptionList = {'UUID', 'proctime', 'methodInvars', 'context'};
    end
  end
 
end