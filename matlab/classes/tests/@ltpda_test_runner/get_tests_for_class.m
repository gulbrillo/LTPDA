% GET_TESTS_FOR_CLASS returns an array of test structures for a particular
% test class.
% 
% The test for the test class is a structure of the form:
% 
%   test.utp     % instance of the unit test class
%   test.methods % a cell-array of the methods to be run
% 

function test = get_tests_for_class(runner, testclass)
  
  test.utp = feval(testclass);
  test.utp.testRunner = runner;
  test.utp.init();
  test.methods = test.utp.list_tests();
  
end

