% TEST_ADD_PLIST tests adding a parameter by plist.
function res = test_add_plist(varargin)
  
  utp = varargin{1};
  
  % Test object
  sys = utp.testData;
  
  % Add a parameter with copied output
  sys2 = sys.addParameters(plist('a', 1));
  
  % Modify by adding two parameters
  sys3 = copy(sys,1);
  sys3.addParameters(plist('b', 2, 'c', 3));
  
  % Check with multiple inputs
  sys4 = addParameters(sys, sys, plist('d', 4));
  
  % Check output class
  assert(isa(sys2, 'ssm'), 'The output of ssm/addParameters should be an ssm object. Got object of class %s', class(sys2));
  assert(isa(sys3, 'ssm'), 'The output of ssm/addParameters should be an ssm object. Got object of class %s', class(sys3));
  assert(isa(sys4, 'ssm'), 'The output of ssm/addParameters should be an ssm object. Got object of class %s', class(sys4));
  
  % Check output sizes
  assert(isequal(numel(sys2), 1), 'Expect a single output ssm for a single input; got %d', numel(sys2));
  assert(isequal(numel(sys3), 1), 'Expect a single output ssm for a single input; got %d', numel(sys3));
  assert(isequal(numel(sys4), 2), 'Expect two output ssms for two inputs; got %d', numel(sys4));
  
  % Check the parameters were added
  assert(isparam(sys2.params, 'a'), 'sys2 should contain a parameter with key ''a''');
  assert(isequal(sys2.params.find('a'), 1), 'sys2 should contain a parameter with key ''a'' and value 1');
  
  assert(isparam(sys3.params, 'b'), 'sys2 should contain a parameter with key ''b''');
  assert(isparam(sys3.params, 'c'), 'sys2 should contain a parameter with key ''c''');
  assert(isequal(sys3.params.find('b'), 2), 'sys2 should contain a parameter with key ''b'' and value 2');
  assert(isequal(sys3.params.find('c'), 3), 'sys2 should contain a parameter with key ''c'' and value 3');
  
  assert(isparam(sys4(1).params, 'd'), 'sys4(1) should contain a parameter with key ''d''');
  assert(isparam(sys4(2).params, 'd'), 'sys4(2) should contain a parameter with key ''d''');
  assert(isequal(sys4(1).params.find('d'), 4), 'sys4(1) should contain a parameter with key ''d'' and value 4');
  assert(isequal(sys4(2).params.find('d'), 4), 'sys4(2) should contain a parameter with key ''d'' and value 4');
  
  % Return message
  res = 'ssm/psd passed ao input tests';
    
end
