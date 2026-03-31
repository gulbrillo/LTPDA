% HISTORY History object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HISTORY History object class constructor.
%              Create a history object.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%              h = history()
%              h = history(proctime, minfo, plist)
%              h = history(proctime, minfo, plist, in_names, oldUUID, in_hists)
%
%              h = history(filename)
%              h = history(structure)
%              h = history(history-object)
%              h = history('database', ...)
%
% INPUTS:      minfo:    Minfo-object which is created in the called method.
%              plist:    Plist-object which is used in the called method.
%              in_names: Variable names which are used for the called method.
%              in_hist:  Older history-objects
%
% SEE ALSO:    ltpda_obj, ltpda_nuo, minfo, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed = true, Hidden = true) history < ltpda_nuo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    methodInfo   = []; % minfo-object which is created in the called method
    plistUsed    = []; % plist-object which is used in the called method
    methodInvars = {}; % variable names which are used for the called method
    inhists      = []; % the older history-objects
    proctime     = []; % creation time of the history object
    UUID         = []; % UUID of the object that was changed
    objectClass  = ''; % The class of the object the history was attached to
    creator      = provenance();
    context      = {}; % Cell-array of names from dbstack
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = public, SetAccess = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.methodInfo(obj, val)
      if ~(isa(val, 'minfo') || isempty(val))
        error('### The value for the property ''methodInfo''\n### must be a minfo-object or empty but\n### it is from the class %s', class(val));
      end
      obj.methodInfo = val;
    end
    function set.plistUsed(obj, val)
      if ~(isa(val, 'plist') || isempty(val))
        error('### The value for the property ''plistUsed''\n### must be a plist-object or empty but\n### it is from the class %s', class(val));
      end
      obj.plistUsed = val;
    end
    function set.methodInvars(obj, val)
      if ~iscell(val)
        error('### The value for the property ''methodInvars''\n### must be a cell-array but\n### it is from the class %s', class(val));
      end
      obj.methodInvars = val;
    end
    function set.inhists(obj, val)
      if ~(isa(val, 'history') || isempty(val) || ischar(val) || iscellstr(val))
        error('### The value for the property ''inhists''\n### must be a history-object or empty but\n### it is from the class %s', class(val));
      end
      obj.inhists = val;
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function obj = history(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          % Do nothing
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          %%%%%%%%%%% From File %%%%%%%%%%%%%%%%
          if ischar(varargin{1})
            
            filename = varargin{1};
            [path, name, ext] = fileparts(filename);
            switch ext
              case '.mat'
                obj = load(filename);
                obj = obj.a;
              case '.xml'
                root_node = xmlread(filename);
                obj = utils.xml.xmlread(root_node, 'history');
              otherwise
                error('### Unknown file type.');
            end
            
            %%%%%%%%%%  h = history(struct)   %%%%%%%%%%
          elseif isstruct(varargin{1})
            obj = fromStruct(obj, varargin{1});
            
            %%%%%%%%%%  h = history(history)   %%%%%%%%%%
          elseif isa(varargin{1}, 'history')
            obj = copy(varargin{1}, 1);
            
            %%%%%%%%%%  h = history(plist)   %%%%%%%%%%
          elseif isa(varargin{1}, 'plist')
            %%% is the plist is empty then return an empty history object
            if nparams(varargin{1}) == 0
              obj.plistUsed = varargin{1};
            else
              error('### Unknown history constructor method.');
            end
            
          else
            error('### Unknown history constructor method.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = history(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          else
            error('### Unknown constructor method for two inputs.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          %%%%%%%%%%  h = history(proctime, minfo, plist)  %%%%
          %%% Use default values
          if ~isempty(varargin{1})
            obj.proctime = varargin{1};
          end
          if ~isempty(varargin{2})
            obj.methodInfo   = varargin{2};
          end
          if ~isempty(varargin{3})
            obj.plistUsed    = varargin{3};
          end
          
        case 6
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   five  inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          %%%%%%%%%%  h = history(proctime, minfo, plist, in_names, oldUUID, in_hists)  %%%%
          
          %%% Use default values
          if ~isempty(varargin{1})
            obj.proctime = varargin{1};
          end
          if ~isempty(varargin{2})
            obj.methodInfo   = varargin{2};
          end
          if isempty(varargin{3})
            obj.plistUsed    = plist();
          else
            obj.plistUsed    = varargin{3};
          end
          
          if ~isempty(varargin{4})
            obj.methodInvars = varargin{4};
          end
          if ~isempty(varargin{5})
            % Don't store the 'old' UUID inside the history object because we
            % use the UUID of the history object for creating the history
            % tree. For this it is necessary that the history have its own
            % independent UUID.
            %
            obj.UUID = varargin{5};
          end
          if ~isempty(varargin{6})
            obj.inhists      = varargin{6};
          end
          
        otherwise
          error('### Unknown number of constructor arguments.');
      end
      
    end
    
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods    
    varargout = getNodes(varargin)
    varargout = hist2dot(varargin)
    varargout = hist2m(varargin)
    varargout = string(varargin)
  end
  
  methods (Hidden = true)
    varargout = getObjectClass(varargin);
    varargout = setObjectClass(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'history');
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
      obj = history.newarray([varargin{:}]);
    end
    
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
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end  
  
end
