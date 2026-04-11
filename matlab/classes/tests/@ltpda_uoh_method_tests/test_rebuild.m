% TEST_REBUILD tests the output of the method can be rebuilt.
function res = test_rebuild(varargin)
  
  utp = varargin{1};
  
  % Method name
  methodName = utp.methodName;
  
  % Method class
  methodClass = utp.className;  
  
  % Apply method
  out = feval(methodName, utp.testData, utp.configPlist);
  
  % Rebuild
  rout = out.rebuild();
    
  % Perform checks
  [res, msg] = isequal(out, rout, utp.exceptionList{:});
  assert(res, 'The result of rebuilding the output method [%s/%s] should be the same. %s', methodClass, methodName, msg);
  
  % Return result message
  res = 'Performed rebuild tests';
end
% END
