% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist  
  pl = plist();  
  p = param({'names', 'A cell-array of parameter names for substitution. A value of ''all'' will result in all parameters being substituted by their numerical values.'}, {'All'});
  pl.append(p);
  
  utp.expectedPlists = pl;  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END