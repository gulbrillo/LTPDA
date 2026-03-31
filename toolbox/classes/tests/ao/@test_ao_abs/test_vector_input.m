function res = test_vector_input(varargin)
  
  utp = varargin{1};
  
  % set test data
  utp.testData = [ao(1) ao(2); ao(3) ao(4)];
  
  % call super
  res = test_vector_input@ltpda_vector_utp(utp);
    
end