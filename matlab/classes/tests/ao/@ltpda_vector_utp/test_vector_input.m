% Test a method with a vector of input objects
function varargout = test_vector_input(varargin)
  
  utp = varargin{1};
 
  in = utp.testData;
  
  % Run the method over the input vector
  out = feval(utp.methodName, in);

  % Check the number of elements is the same
  assert(numel(out) == numel(in));
  
  % Check the result against matlab
  for kk=1:numel(out)
    y = feval(utp.methodName, in(kk).y);
    assert(isequal(y, out(kk).y));
  end
  
  varargout{1} = sprintf('Test vector of inputs for %s/%s', utp.className, utp.methodName);
  
end
