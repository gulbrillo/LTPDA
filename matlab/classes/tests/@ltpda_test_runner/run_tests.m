% RUN_TESTS runs different configurations of units tests.
% 
% CALL:
%       runner = ltpda_test_runner();
% 
% The following calls are supported:
%   runner.run_tests() % all tests under the current directory
%   runner.run_tests('all') % all
%   runner.run_tests('models') % only models
%   runner.run_tests('classes') % only models
%   runner.run_tests(<test_class>) % all tests in test class
%   runner.run_tests(<test_class>, {... methods ...}) % only particular tests in test class
%

function varargout = run_tests(varargin)
  
  runner = varargin{1};
  tests = [];
  
  current_path = path();
  
  % Buil test list
  switch nargin
    case 1 % run all under this directory
      tests = [tests runner.get_tests_in_dir('.')];
    case 2
      str = lower(varargin{2});
      switch str
        case 'all'
          tests = [tests runner.get_builtin_model_tests()];
          tests = [tests runner.get_class_tests()];
        case 'models'
          tests = [tests runner.get_builtin_model_tests()];
        case 'classes'
          tests = [tests runner.get_class_tests()];
        otherwise
          tests = [tests runner.get_tests_for_class(varargin{2})];
      end
      
    case 3
      
      % all tests for this test class
      tests = runner.get_tests_for_class(varargin{2});
      % then set the requested methods
      methods = varargin{3};
      if ischar(methods)
        methods = {methods};
      end
      tests.methods = methods;
      
    otherwise
      help(mfilename);
      error('incorrect inputs');
  end
  
  % run tests
  runner.run_test_list(tests);
  
  path(current_path);
  savepath;
  
end