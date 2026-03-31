% LTPDA_UOH is the abstract ltpda base class for ltpda user object classes with history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_UOH is the ltpda base class for ltpda user object classes
%              This class is an abstract class and it is not possible to create
%              an instance of this class.
%
% SUPER CLASSES: ltpda_uo < ltpda_obj
%
% SUB CLASSES:   ao, filterbank, timespan, ssm, smodel, pest, matrix, collection, ltpda_tf
%
% LTPDA_UOH PROPERTIES:
%
%     Protected Properties (read only)
%       UUID          - Universally Unique Identifier of 128-bit
%       description   - description of the object
%       hist          - history of the object (history object)
%       name          - name of the object
%       plotinfo      - plist with the plot information
%       procinfo      - plist with additional information for an object.
%
% SEE ALSO:    ltpda_obj, ltpda_uo, ltpda_tf, ltpda_filter,
%              ao, miir, mfir, filterbank, timespan, pzmodel, history, ssm,
%              parfrac, rational, smodel, pest, matrix, collection
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_uoh < ltpda_uo
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    hist         = []; % history of the object (history object)
    historyArray = []; % array of history objects for saving
    procinfo     = []; % plist with additional information for an object.
    plotinfo     = []; % plotinfo object
  end
  
  properties (SetAccess = protected, GetObservable = true)
    timespan     = []; % a timespan indicating the valid time-range of the object
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function set.timespan(obj, val)
      if ~isempty(val) && ~isa(val, 'timespan')
        error('### The value for the property ''timespan'' must be a timespan object or a time, a string or a double.');
      end
      obj.timespan = val;
    end
    function set.hist(obj, val)
      if ~(isa(val, 'history') || isempty(val) || ischar(val)) % char is allowed for compressing history
        error('### The value for the property ''hist'' must be\n### a history-object or empty but it is\n### from the class %s', class(val));
      end
      obj.hist = val;
    end
    function set.procinfo(obj, val)
      if ~isa(val, 'plist') && ~isempty(val)
        error('### The value for the property ''procinfo'' should be a plist but it is from the class [%s]', class(val));
      end
      if isempty(val) || isempty(val.params)
        obj.procinfo = [];
      else
        obj.procinfo = val;
      end
    end
    function set.plotinfo(obj, val)
      if ~isa(val, 'plotinfo') && ~isempty(val)
        error('### The value for the property ''plotinfo'' should be a plotinfo but it is from the class [%s]', class(val));
      end
      if isempty(val)
        obj.plotinfo = [];
      else
        obj.plotinfo = val;
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_uoh(varargin)
      % Check the supported version
      utils.helper.checkMatlabVersion;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = index(varargin)
    varargin  = creator(varargin)
    varargin  = created(varargin)
    varargout = csvexport(varargin)
    varargout = setPlotinfo(varargin)
    varargout = setProcinfo(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = saveobj(varargin)
    varargout = addHistory(varargin)
    varargout = setProperties(varargin)
    varargout = clearHistory(varargin)
    varargout = setHist(obj, val)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_uoh');
    end
    
    function out = SETS()
      out = SETS@ltpda_uo;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ltpda_uoh.newarray([varargin{:}]);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
    varargout = testCallerIsMethod(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = addHistoryWoChangingUUID(varargin)
    varargout = csvGenerateData(varargin)
    varargout = setPropertyValue(varargin)
    varargout = setObjectProperties(varargin)
    varargout = fromRepository(varargin)
    varargout = fromModel(varargin)
    varargout = fromStruct(varargin)
    varargout = getObjectTimeRange(varargin)
    varargout = prepareSinfoForSubmit(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static, Access = protected)
    
    function out = buildplist(out, set)
      out = buildplist@ltpda_uo(out, set);
      switch lower(set)
      end
    end
    
    function pl = addGlobalKeys(pl)
      % Name
      p = param({'Name','The name of the constructed object.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Description
      p = param({'Description','The description of the constructed object.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Timespan
      pl.append({'Timespan', 'Give a timespan for the object.'}, paramValue.EMPTY_DOUBLE);
      
      % callerIsMethod
      pl.append({'callerIsMethod', 'Allow an override of the caller is method feature.'}, paramValue.EMPTY_DOUBLE);
      
    end
    
    function pl = removeGlobalKeys(pl)
      pl.remove('name');
      pl.remove('description');
      pl.remove('timespan');
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (abstract)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Abstract)
    varargout = generateConstructorPlist(varargin)
  end
  
end

