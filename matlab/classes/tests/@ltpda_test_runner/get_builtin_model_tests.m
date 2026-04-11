% GET_BUILTIN_MODEL_TESTS returns an array of test structures.
% 
% The tests for the built-in model test classes are gathered in to an array
% of structures of the form:
% 
%   test.utp     % instance of the unit test class
%   test.methods % a cell-array of the methods to be run
% 

function tests = get_builtin_model_tests(runner)
  
  tests = [];
  % Run all tests in built-in models dirs <models>/tests
  paths = utils.models.getBuiltinModelSearchPaths();
  
  for kk=1:numel(paths)
    path = fullfile(paths{kk}, 'tests');    
    tests = [tests runner.get_tests_in_dir(path)];    
  end
  
  % and add the new extension modules built-in models and class tests
  prefs = getappdata(0, 'LTPDApreferences');
  searchPaths = prefs.getExtensionsPrefs.getSearchPaths;
  for kk=0:searchPaths.size-1
    path = fullfile(char(searchPaths.get(kk)), 'tests');
    tests = [tests runner.get_tests_in_dir(path)];    
  end
  
end