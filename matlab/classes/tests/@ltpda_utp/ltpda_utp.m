% LTPDA_UTP is the base class for ltpda unit test plan classes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   LTPDA_UTP is the base class for ltpda unit
%                test plan classes.
%
% SUPER CLASSES: handle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ltpda_utp < handle
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
    testData    = []; % a place-holder for test data
    configPlist = []; % a place-holder for a config plist
    methodName  = ''; % method name we want to test
    className   = ''; % class name of the method we want to test
    testRunner  = [];
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = protected, SetAccess = protected)
  end
  
  % constant properties
  properties (Dependent = true)
    ntests; % the number of tests in this plan
  end
  
  % constant properties access methods
  methods
    function value = get.ntests(obj)
      tests = obj.list_tests();
      value = numel(tests);
    end
    
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
    function obj = ltpda_utp(varargin)
      obj.startup();
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function startup(obj)
      % do nothing
    end
    
    function tests = list_tests(varargin)
      utp = varargin{1};
      tests = {};
      mths = methods(utp);
      for kk=1:numel(mths)
        mth = mths{kk};
        if strncmp(mth, 'test_', 5) && ~strcmp(mth, class(utp))
          tests = [tests {mth}];
        end
      end
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
    
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

