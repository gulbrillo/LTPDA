classdef test_ao_abs < ltpda_vector_utp & ltpda_uoh_method_tests
  
  methods    
    function utp = test_ao_abs()
      utp = utp@ltpda_vector_utp();
      utp.methodName = 'abs';
      utp.className = 'ao';
      utp.testData = ao.randn(10,10);
      utp.exceptionList = [utp.exceptionList {'name'}];
    end
  end
  
end