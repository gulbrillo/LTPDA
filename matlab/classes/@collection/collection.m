% COLLECTION constructor for collection class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COLLECTION constructor for collection class.
%
% CONSTRUCTOR:
%
%       fb = collection()      - creates an empty collection object
%       fb = collection(objs)  - construct from an array of objects
%       fb = collection(pl)    - create a collection object from a parameter list
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'collection')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef collection < ltpda_container
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
    objs = {}; % Objects in collection
    names = {}; % Names of the objects of the collection.
  end
  
  properties (Dependent)
    numel    % The number of objecs
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function value = get.numel(obj)
      value = numel(obj.objs);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.objs(obj, val)
      if ~iscell(val)
        error('### The value for the property ''objs'' must be a cell object');
      end
      if isempty(val)
        obj.objs = {};
      else
        obj.objs = reshape(val, 1, []);
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = collection(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          % set a default plist
          obj.addHistory(collection.getInfo('collection', 'None'), collection.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || (iscell(varargin{1}) && iscellstr(varargin{1}))
            %%%%%%%%%%   c = collection('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   c = collection('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   c = collection({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif iscell(varargin{1})
            %%%%%%%%%%   r = collection(cell-array)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from cell-array');
            inObjs = varargin{1};
            obj = fromInput(obj, inObjs{:});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   r = collection(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'ltpda_uoh')
            %%%%%%%%%%  f = collection(a1)   %%%%%%%%%%
            obj = obj.fromInput(varargin{:});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   r = collection(plist)   %%%%%%%%%%
            pl = varargin{1};
            
            if numel(pl) > 1
              % The input is a vector of PLISTS
              obj = obj.fromInput(pl);
              
            else
              
              if pl.isparam_core('filename') || pl.isparam_core('filenames')
                utils.helper.msg(msg.PROC2, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
                obj = obj.fromFile(pl);
                
              elseif pl.isparam_core('built-in')
                utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
                obj = fromModel(obj, pl);
                
              elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
                utils.helper.msg(msg.PROC2, 'constructing from repository %s', pl.find_core('hostname'));
                obj = obj.fromRepository(pl);
                
              elseif pl.isparam_core('objs')
                obj = obj.fromInput(pl);
                
              else
                if pl.shouldIgnore()
                  % The PLIST is not a configuration PLIST
                  obj = obj.fromInput(plist('objs', {pl}));
                else
                  pl = applyDefaults(collection.getDefaultPlist('Default') , pl);
                  obj.setObjectProperties(pl);
                  obj.addHistory(collection.getInfo('collection', 'None'), pl, [], []);
                end
              end
              
            end
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'ltpda_uo') && isa(varargin{2}, 'ltpda_uo')
            %%%%%%%%%%  f = collection(a1, a2)   %%%%%%%%%%
            obj = obj.fromInput(varargin{:});
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   collection('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  f = collection(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = collection(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   collection(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = collection(varargin{2});
              else
                obj = collection(varargin{1});
              end
            else
              obj = collection(varargin{2});
            end
          else
            obj = obj.fromInput(varargin{:});
          end
          
        otherwise
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   any input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   collection('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            obj = obj.fromInput(varargin{:});
          end
      end
      
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = setObjs(varargin)
    varargout = setObjectAtIndex(varargin)
    varargout = getObjectAtIndex(varargin)
    varargout = removeObjectAtIndex(varargin)
    varargout = getObjectsOfClass(varargin)
    varargout = saveAllObjects(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = subsref(varargin)
    varargout = subsasgn(varargin)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function out = SETS()
      out = [SETS@ltpda_uoh, {'From Input'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if isempty(pl) || ~strcmp(lastset, set)
        pl = collection.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = collection.newarray([varargin{:}]);
    end
    
    varargout = identifyInsideObjs(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromRepository(varargin)
    varargout = fromInput(varargin)
    varargout = fromStruct(varargin)
    varargout = getObjectByName(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(collection.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = collection.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from input'
          p = param({'objs', 'Objects of the collection.<br>Please use a cell array if the objects are not from the same type.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          p = param({'names', 'Names of the objects of the collection.'}, paramValue.EMPTY_CELL);
          out.append(p);
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end

