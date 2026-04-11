% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist  
  utp.expectedPlists = plist();  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END