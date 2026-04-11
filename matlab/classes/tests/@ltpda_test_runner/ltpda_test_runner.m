% LTPDA_TEST_RUNNER can be used to run unit tests for LTPDA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   LTPDA_TEST_RUNNER can be used to run unit tests for LTPDA.
% The class exposes a method called 'run_tests' which can run different
% configurations of tests.
%
% >> help ltpda_test_runner.run_tests
%
% SUPER CLASSES: handle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ltpda_test_runner < handle
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
    output = 0;
    results = [];
    includeRepositoryTests = false;
    includeClassTests      = false;
    includeModelTests      = false;
    includeExtensionTests  = false;
    repositoryPlist        = [];
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = protected, SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_test_runner(varargin)
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function res = skipRepoTests(runner)
      pl = runner.repositoryPlist;
      if isa(pl, 'plist')
        % Add necessary parameter for auto tests
        pl.combine(plist('no dialog', true, 'use selector', false));
        
        if  pl.isparam('hostname') && ...
            pl.isparam('database') && ...
            pl.isparam('username') && ...
            pl.isparam('password')
          res = false;
        else
          res = true;
        end
      else
        res = true;
      end
    end
    
    function c = failureCount(runner)
      c = 0;
      for kk=1:numel(runner.results)
        r = runner.results(kk);
        if ~r.passed
          c = c+1;
        end
      end
    end
    
    function dumpResults(runner)
      printer = ut_result_printer(runner);
      printer.dump();
    end
    
    function clear(varargin)
      runner = varargin{1};
      runner.results = [];
    end
    
    function appendErrorResult(runner, utp, method, Me)
      result = ut_result(utp,method);
      result.passed = false;
      result.message = ut_result.formatException(Me);
      result.finish;
      runner.appendResult(result);
    end
    
    function appendResult(runner, result)
      if isa(result, 'ut_result')
        result.finish();
        runner.results = [runner.results result];
      else
        error('Can''t append an object of type %s to the results list', class(result));
      end
    end
    
    function txt = char(varargin)
      txt = 'ltpda_test_runner object';
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = addlistener(varargin);
    varargout = notify(varargin);
    varargout = delete(varargin);
    varargout = findobj(varargin);
    varargout = findprop(varargin);
    varargout = ge(varargin);
    varargout = gt(varargin);
    varargout = le(varargin);
    varargout = lt(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = protected)
    
    varargout = run_test_list(varargin)
    varargout = get_builtin_model_tests(varargin)
    varargout = get_class_tests(varargin)
    varargout = get_tests_for_class(varargin)
    varargout = get_tests_in_dir(varargin)
    
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
    
    % RUN_TESTS provides a convenient static interface to
    % ltpda_test_runner/run_tests.
    function RUN_TESTS(varargin)
      runner = ltpda_test_runner();
      runner.run_tests(varargin{:});
      runner.dumpResults();
    end
    
    % RUN_TESTS provides a convenient static interface to
    % run all tests.
    function RUN_ALL_TESTS
      runner = ltpda_test_runner();
      runner.run_tests('all');
      runner.dumpResults();
    end
    
    % RUN_TESTS provides a convenient static interface to
    % run all model tests.
    function RUN_MODEL_TESTS
      runner = ltpda_test_runner();
      runner.run_tests('models');
      runner.dumpResults();
    end
    
    % RUN_TESTS provides a convenient static interface to
    % run all class tests.
    function RUN_CLASS_TESTS
      runner = ltpda_test_runner();
      runner.run_tests('classes');
      runner.dumpResults();
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_utp');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
  end
  
end

