% GET_CLASS_TESTS returns an array of test structures.
% 
% The tests for the toolbox classes are gathered in to an array of
% structures of the form:
% 
%   test.utp     % instance of the unit test class
%   test.methods % a cell-array of the methods to be run
% 

function tests = get_class_tests(runner)
  
  % look in the system test directory
  loc = which('ltpda_startup');
  idx = strfind(loc, filesep);
  loc = loc(1:idx(end));
  loc = fullfile(loc, '..', '..', 'classes', 'tests');
  
  tests = runner.get_tests_in_dir(loc);  
  
end