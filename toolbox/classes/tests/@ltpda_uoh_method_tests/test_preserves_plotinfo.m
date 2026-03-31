% TEST_PRESERVES_PLOTINFO tests this method doesn't delete the plot info.
function res = test_preserves_plotinfo(varargin)
  
  utp = varargin{1};
  
  % Method name
  methodName = utp.methodName;
  
  % Method class
  methodClass = utp.className;
  
  % Get test data
  sys = utp.testData;  
  assert(isa(sys, methodClass), 'The test data for this test should be of class %s', methodClass);
  
  % Set plot info
  pi = plotinfo('-', 2, 'r', 'none', 10);
  sys = sys.setPlotinfo(pi);
  
  % Run the method
  out = feval(methodName, sys, utp.configPlist);
  
  % check output
  assert(~isempty(out.plotinfo), 'The output object should not have an empty plotinfo');
  
  % We could check the content of the plotinfo.
  
  % Return result message
  res = 'Method preserves plot info';
end
% END