% TEST_DISPLAYMETHODINFO tests the method has a displayMethodInfo in the help.
function res = test_displayMethodInfo(varargin)
  
  utp = varargin{1};
  
  % Method name
  methodName = utp.methodName;
  
  % Method class
  methodClass = utp.className;
  
  % String to look for
  testString = sprintf('<a href="matlab:utils.helper.displayMethodInfo(''%s'', ''%s'')">Parameters Description</a>', methodClass, methodName);
  
  % Load contents of mfile
  text = fileread(which([methodClass '/' methodName]));
  
  idx = strfind(text, testString);
  assert(~isempty(idx), 'The file for method [%s, %s] should contain a displayMethodInfo tag in the help text', methodClass, methodName);
  
  % Return result message
  res = 'Performed displayMethodInfo tests';
end
% END