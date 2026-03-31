% PARAM Parameter object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARAM Parameter object class constructor.
%              Create a parameter object.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       p = param();                - creates an empty parameter
%       p = param(pl)               - creates a parameter from a
%                                     parameter list with the parameters:
%                                   - 'key' and 'val', or
%       p = param('key', val)       - creates a key/value pair
%                                     'val' can be from any type
%       p = param({key, desc}, val) - creates a key/value pair and a
%                                     description for the key
%       p = param('key', val, desc) - creates a key/value pair and a
%                                     description for the key
%
% SEE ALSO: ltpda_obj, ltpda_nuo, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed = true, Hidden = true) param < ltpda_nuo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  properties (Dependent=true)
    defaultKey
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    key     = '';
    val     = [];   % value of the key/value pair
    desc    = '';   % description of the key/value pair
    readonly = false;
    origin = '';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.key(obj, val)
      if obj.readonly
        error('Plist is readonly. Copy it before trying to modify it.');
      end
      if ischar(val) || iscellstr(val)
        obj.key = upper(val);
      else
        error('### The value for the property ''key'' must be a string\n### but it is from the class %s', class(val));
      end
    end
    
    function obj = set.val(obj, val)
      if obj.readonly
        error('Plist is readonly. Copy it before trying to modify it.');
      end
      obj.val = val;
    end
    
    function obj = set.desc(obj, val)
      if obj.readonly
        error('Plist is readonly. Copy it before trying to modify it.');
      end
      obj.desc = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function val = get.defaultKey(obj)
      if iscell(obj.key)
        val = obj.key{1};
      else
        val = obj.key;
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = param(varargin)
      
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
          
          if isa(varargin{1}, 'param')
            %%%%%%%%%%  obj = param(param)   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  obj = param(plist)   %%%%%%%%%%
            
            if nparams(varargin{1}) == 0
              %%%%%%%%%%  obj = param(plist())   %%%%%%%%%%
              %%%%%%%%%%  obj = param(plist('KEY', 'a', 'VAL', 1))   %%%%%%%%%%
              %%% is the plist is empty then return an empty param object
              
            else
              pl = varargin{1};
              pl_key  = find_core(pl, 'key');
              pl_val  = find_core(pl, 'val');
              pl_desc = find_core(pl, 'desc');
              if isempty(pl_key)
                error('### building a parameter from a plist requires one parameter in the plist is called ''key''');
              end
              if isempty(pl_val)
                error('### building a parameter from a plist requires one parameter in the plist is called ''val''');
              end
              
              obj.key  = pl_key;
              obj.val  = pl_val;
              if ~isempty(pl_desc)
                if ~ischar(pl_desc)
                  error('### The description of a parameter must be a string but it is from the class [%s]', class(pl_desc));
                end
                obj.desc = pl_desc;
              end
            end
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  obj = param(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          else
            error('### unknown constructor type for param object.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if iscell(varargin{1})
            %%%%%%%%%%  obj = param({'key', 'desc'}, ...)   %%%%%%%%%%
            obj.key = varargin{1}{1};
            if ischar(varargin{1}{2});
              obj.desc = varargin{1}{2};
            else
              error('### The description of a parameter must be a string but it is from the class [%s]', class(varargin{1}{2}));
            end
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl')
            %%%%%%%%%%   obj = param(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            return
            
          else
            %%%%%%%%%%  obj = param('key', ...)   %%%%%%%%%%
            obj.key = varargin{1};
          end
          
          if  iscell(varargin{2})       && ...
              numel(varargin{2}) == 3   && ...
              isnumeric(varargin{2}{1}) && ...
              iscell(varargin{2}{2}) && ...
              isnumeric(varargin{2}{3})
            %%%%%%%%%%  obj = param(..., {idx2options, {options}, selectionMode})   %%%%%%%%%%
            %%%%%%%%%%  example: param(..., {1, {1 2 3}, 0})   %%%%%%%%%%
            %%%%%%%%%%  example: param(..., {1, {'a' 'b' 'c'}, 0})   %%%%%%%%%%
            obj.val = paramValue(varargin{2}{1}, varargin{2}{2}, varargin{2}{3});
            
          else
            obj.val = varargin{2};
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          obj.key  = varargin{1};
          obj.val  = varargin{2};
          if ischar(varargin{3})
            obj.desc = varargin{3};
          else
            error('### The description of a parameter must be a string but it is from the class [%s]', class(varargin{1}{2}));
          end
          
        otherwise
          error('### Unknown number of arguments.');
      end
      
      % REMARK: It is necessary to loop over the objects because fromStruct
      %         and/or fromFile might return more objects than one.
      for ii=1:numel(obj)
        % check if we need to keep a param value or not
        if isa(obj(ii).val, 'paramValue') && numel(obj(ii).val.options) == 1 && ...
            isempty(obj(ii).val.property)
          obj(ii).val = obj(ii).val.options{1};
        end
      end
      
      % set origin
      obj.setOriginInConstructor();
      
    end % End of constructor
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    varargout = mux(varargin);
    varargout = string(varargin)
    
    varargout = setKey(varargin)
    varargout = setVal(varargin)
    varargout = setDesc(varargin)
    varargout = setKeyVal(varargin)
    
    varargout = getVal(varargin)
    varargout = getDefaultVal(varargin)
    varargout = getOptions(varargin)
    
    varargout = setProperty(varargin)
    varargout = getProperty(varargin)
    
    p = setDefaultOption(p, option)
    p = setDefaultIndex(p, index)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public, hidden)                     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = setReadonly(varargin)
  end
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    
    function setOriginInConstructor(obj)
      
      % Now let's try to capture some context of where this parameter was
      % created.
      stack = dbstack('-completenames');
      
      % ignore setOrigin
      stack = stack(2:end);
      
      % filter out first param/plist methods
      idx   = cellfun(@isempty, regexp({stack.file}, sprintf('@(param|plist)%s', filesep), 'once'));
      stack = stack(idx);
      
      % filter out some exceptions
      exceptions = {'LTPDAPipeline.runStep', 'applymethod', 'setPropertyValue'};
      stackNames = {stack.name};
      exceptionsIdx = utils.helper.ismember(stackNames, exceptions);
      stack = stack(~exceptionsIdx);
      stackNames = stackNames(~exceptionsIdx);

      % There is no stack left -> leave the origin empty
      if isempty(stackNames)
        return
      end
      
      idxGetInfo = find(strcmp(stackNames, 'getInfo'), true, 'first');
      if ~isempty(idxGetInfo)
        % Rule 1: The origin is the method behind the frist 'getInfo'
        idxMethod = idxGetInfo+1;
      else
        % Rule 2: The origin is the method behind the frist 'getDefaultPlist'
        %         This is necessary for methods who uses ao/applymethod
        %         like ao/max
        idxgetDefPl = find(strcmp(stackNames, 'getDefaultPlist'), true, 'first');
        if ~isempty(idxgetDefPl)
          idxMethod = idxgetDefPl+1;
          if strcmp(stackNames{idxMethod}, 'processModelInputs')
            % Special case for models. Here is the stack:
            %   'getDefaultPlist'
            %   'processModelInputs'
            %   'mainFnc'
            %   'ao_model_retrieve_in_timespan'
            idxMethod = idxMethod + 2;
          end
        else
          % Rule 3: The origin is the fist entry of the stack
          idxMethod = 1;
        end
      end
      
      stackOrigin = stackNames{idxMethod};
      
      % Special case for constructors
      clName = regexp(stackOrigin, '(\w+)\.\1$', 'tokens');
      if ~isempty(clName)
        % For the case that the last stack name is a constructor then use
        % only the constructor name 'ao' and not 'ao.ao'.
        stackOrigin = clName{1}{1};
      elseif ~isempty(regexp(stackOrigin, '\.getInfo$', 'once'))
        % For constructor PLISTs is the last stack entry:
        % <CLASSNAME>.getInfo
        stackOrigin = strtok(stackOrigin, '.');
      end
      
      % Add package name to origin
      fName = stack(idxMethod).file;
      % Regular expression for nested packages
      package = regexp(fName, '\+(.*)@', 'tokens');
      if ~isempty(package)
        % This is necessary if we have nested packages
        package = package{1}{1};
        package = strrep(package, filesep, '.');
        package = strrep(package, '+', '');
        stackOrigin = strcat(package, stackOrigin);
      end
      
      for kk=1:numel(obj)
        obj(kk).origin = stackOrigin;
      end
      
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'param');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set');
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = param.newarray([varargin{:}]);
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
  
end

