% TESTDESCRIPTION This class collects all information about a test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TESTDESCRIPTION This class collects all information about
%                a test.
%
% SUPER CLASSES: handle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef TestDescription < handle
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
    testName         = '';
    testLocation     = '';
    testDescription  = 'Unknown test description';
    checkResults = {};
    result       = TestDescription.FAILED;
  end
  
  properties (Dependent = true)
    testClass
    testMethod
    nchecks
  end
  
  properties (Constant=true, Hidden=true)
    PASSED  = 'passed';
    SKIPPED = 'skipped';
    FAILED  = 'failed';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                  Setter                                   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                  Getter                                   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function value = get.nchecks(self)
      value = numel(self.checkResults);
    end
    function value = get.testClass(self)
      value = regexp(self.testLocation, '@\w+', 'match');
      if isempty(value)
        value = '';
      else
        value = value{1};
      end
    end
    function value = get.testMethod(self)
      value = regexp(self.testLocation, '\w+.?m?$', 'match');
      if isempty(value)
        value = '';
      else
        value = value{1};
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function self = TestDescription(varargin)
      
      switch nargin
        case 1
          self.description = varargin{1};
      end
      
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function txt = char(obj)
      txt = sprintf('[%dx%d %s]', size(obj), class(obj));
    end
    function addCheckResult(self, val)
      if any(strcmp(self.checkResults, val))
        % Don't add the result because we have alreayd added this result
        % This can happen if the user calls the same check function with
        % different test data. For example inside a loop.
      else
        self.checkResults = [self.checkResults val];
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = addlistener(varargin);
    varargout = copy(varargin);
    varargout = delete(varargin);
    varargout = findobj(varargin);
    varargout = findprop(varargin);
    varargout = ne(varargin);
    varargout = eq(varargin);
    varargout = ge(varargin);
    varargout = gt(varargin);
    varargout = le(varargin);
    varargout = lt(varargin);
    varargout = notify(varargin);
  end
  
end

