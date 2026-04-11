% GET_TESTS_IN_DIR returns an array of test structures for the test classes
% under the given directory.
%
% The tests for the test classes found below the given directory are
% gathered in to an array of structures of the form:
%
%   test.utp     % instance of the unit test class
%   test.methods % a cell-array of the methods to be run
%

function tests = get_tests_in_dir(runner, directory)
  
  tests = [];
  % generate a list of class directories under this
  classdirs = utils.prog.dirscan(directory, '@.*');
  
  for jj=1:numel(classdirs)
    [path, name, ext] = fileparts(classdirs{jj});
    clname = name(2:end);
    if strncmp(clname, 'test_', 5)
      
      try
        obj = feval(clname);
        obj.testRunner = runner;
        obj.init();
        if isa(obj, 'ltpda_utp')
          test.utp = obj;
          test.methods = obj.list_tests();
          tests = [tests test];
        end
      catch Me
        % Catch the failure if the initialisation fails.
        runner.appendErrorResult(clname, 'All methods', Me);
      end
    end
  end
  
  
end
