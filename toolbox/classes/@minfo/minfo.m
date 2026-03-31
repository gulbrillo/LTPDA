% MINFO a helper class for LTPDA methods.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MINFO is a helper class for LTPDA methods. It holds minformation about the
% method.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%     
%       m = minfo()               - creates an empty object
%       m = minfo(mname,      ... - 
%                 mclass,     ...
%                 mpackage,   ...
%                 mcategory,  ...
%                 mversion,   ...
%                 param_sets, ...
%                 plists,     ...
%                 argsmin,    ...
%                 argsmax)
%
% SEE ALSO: ltpda_obj, ltpda_nuo, history
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) minfo < ltpda_nuo
  
  %------------------------------------------------
  %---------- Private read-only Properties --------
  %------------------------------------------------
  properties (SetAccess = protected)
    mname     = ''; % The method name
    mclass    = ''; % The method class
    mpackage  = 'ltpda'; % The package (if applicable)
    mcategory = ''; % The category of the method
    mversion  = ''; % The cvs-version of the method
    description = ''; % description of the model or method
    children  = [];
    sets      = {}; % A cell array of parameter set names
    plists    = []; % An array of parameter lists
    argsmin   = 1; % Minimum number of input arguments [0 is unbounded]
    argsmax   = -1; % Maximum number of input arguments [0 is unbounded]
    outmin    = 1; % Minimum number of output arguments
    outmax    = -1; % Maximum number of output arguments
    modifier  = true; % Can the method be used as a modifier
    supportedNumTypes = {'double'};
  end
  
  properties (SetAccess = protected)
  end
  
  %------------------------------------------------
  %-------- Declaration of public methods --------
  %------------------------------------------------
  methods
    
    %------------------------------------------------
    %-------- Property rules                 --------
    %------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                Constructor                                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ii = minfo(varargin)
      
      switch nargin
        case 0
        case 1
          
          if isstruct(varargin{1})
            %%%%%%%%%%   ii = minfo(structure)   %%%%%%%%%%
            %%%%%%%%%%   necessary for readxml   %%%%%%%%%%
            ii = fromStruct(ii, varargin{1});
          elseif isa(varargin{1}, 'minfo')
            ii = copy(varargin{1}, 1);
          else
            ii.mname = varargin{1};
          end
          
        case 2
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = minfo(DOM node, history-objects)   %%%%%%%%%%
            %%%%%%%%%%   necessary for reading new XML files   %%%%%%%%%%
            ii = fromDom(ii, varargin{1}, varargin{2});
            
          else
            ii.mname = varargin{1};
            ii.mclass = varargin{2};
          end
        case 3
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
        case 4
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
        case 5
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion = varargin{5};
        case 6
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion = varargin{5};
          ii.sets = varargin{6};
        case 7
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion = varargin{5};
          ii.sets = varargin{6};
          % add plists until we have at least as many as set
          % descriptions
          pls = varargin{7};
          while numel(pls) < numel(ii.sets)
            pls = [pls plist];
          end
          ii.plists = pls;
          % Check we have one set description per plist
          if numel(ii.plists) ~= numel(ii.sets)
            dummySets = ii.sets;
            while numel(dummySets) < numel(ii.plists)
              dummySets = [dummySets {''}];
            end
            ii.sets = dummySets;
          end
        case 8
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion = varargin{5};
          ii.sets = varargin{6};
          % add plists until we have at least as many as set
          % descriptions
          pls = varargin{7};
          while numel(pls) < numel(ii.sets)
            pls = [pls plist];
          end
          ii.plists = pls;
          % Check we have one set description per plist
          if numel(ii.plists) ~= numel(ii.sets)
            dummySets = ii.sets;
            while numel(dummySets) < numel(ii.plists)
              dummySets = [dummySets {''}];
            end
            ii.sets = dummySets;
          end
          ii.argsmin = varargin{8};
        case 9
          ii.mname = varargin{1};
          ii.mclass = varargin{2};
          ii.mpackage = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion = varargin{5};
          ii.sets = varargin{6};
          % add plists until we have at least as many as set
          % descriptions
          pls = varargin{7};
          while numel(pls) < numel(ii.sets)
            pls = [pls plist];
          end
          ii.plists = pls;
          % Check we have one set description per plist
          if numel(ii.plists) ~= numel(ii.sets)
            dummySets = ii.sets;
            while numel(dummySets) < numel(ii.plists)
              dummySets = [dummySets {''}];
            end
            ii.sets = dummySets;
          end
          ii.argsmin = varargin{8};
          ii.argsmax = varargin{9};
        case 12
          % Necessary for the string-method.
          ii.mname     = varargin{1};
          ii.mclass    = varargin{2};
          ii.mpackage  = varargin{3};
          ii.mcategory = varargin{4};
          ii.mversion  = varargin{5};
          ii.sets      = varargin{6};
          if ~isempty(varargin{7})
            ii.plists    = varargin{7};
          end
          ii.argsmin   = varargin{8};
          ii.argsmax   = varargin{9};
          ii.outmin    = varargin{10};
          ii.outmax    = varargin{11};
          ii.modifier  = varargin{12};
          
        otherwise
          error('### Unknown number of constructor arguments');
      end
      
      for kk=1:numel(ii)
        % Special handling of static methods (like those in the MCMC class)
        m = meta.class.fromName(ii(kk).mclass);
        
        % we only handle those which derive from ltpda_algorithm
        if ~isempty(m) && ~strcmp(m.SuperclassList(1).Name, 'ltpda_algorithm')
          continue
        end
        
        if ~isempty(m)
          % is this step a method of the class? (built-in models are not!)
          idx = strcmp({m.MethodList.Name}, ii(kk).mname);
          if any(idx)
            % check if the method is static
            if m.MethodList(idx).Static
              % check the prefix is on the method name
              if strncmp(ii(kk).mname, [ii(kk).mclass '.'], length(ii(kk).mclass)+1) == false
                ii(kk).mname = [ii(kk).mclass '.' ii(kk).mname];
              end
            end
          end
        end
      end
      
      % add a check on the package
      for kk=1:numel(ii)
        if isempty(ii(kk).mpackage)
          error('The mpackage field can not be empty');
        end
        
        % read hashes
        hashes = gitHash();
        if isfield(hashes, ii(kk).mpackage)
          ii(kk).mversion = hashes.(ii(kk).mpackage);
        elseif isempty(ii(kk).mpackage)
          % Avoid printing the warning for empty package names because it
          % might be possible that older files stored an empty string.
          ii(kk).mversion = hashes.ltpda;
        else
          if ltpda_mode == utils.const.msg.DEBUG
            warning('The package [%s] has no known hash. Using the default ltpda hash instead.', ii(kk).mpackage);
          end
          ii(kk).mversion = hashes.ltpda;
        end
      end
    end % End of constructor
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    varargout = setMversion(varargin)
    varargout = setModifier(varargin)
    varargout = setArgsmax(varargin)
    varargout = setArgsmin(varargin)
    varargout = setOutmin(varargin)
    varargout = setOutmax(varargin)
    varargout = setMclass(varargin)
    varargout = addChildren(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = clearSets(varargin)
    varargout = getEncodedString(varargin)
  end  
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function c = allNumericDataTypes()
      % allNumericDataTypes This method returns a cell array of all
      % MATLAB's numeric types including 'logical'
      c = {'double', 'single', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64', 'logical'};
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'minfo');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set);
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = minfo.newarray([varargin{:}]);
    end
    
    varargout = getInfoAxis(varargin);
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Private)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  methods (Static = true, Hidden = true)
    varargout = setFromEncodedInfo(varargin)
  end
  
end

