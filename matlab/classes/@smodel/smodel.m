% SMODEL constructor for smodel class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SMODEL constructor for smodel class.
%
% CONSTRUCTOR:
%
%       mdl = smodel()             - creates an empty smodel object
%       mdl = smodel('foo.mu')     - construct from MuPAD file
%       mdl = smodel('expression') - construct from a expression
%                                        description
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'smodel')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef smodel < ltpda_uoh
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    expr = msym(''); % Expression of the model
    params = {}; % Parameters which are used in the model
    values = {}; % Default values for the parameters
    trans  = {}; % Transformation strings mapping xvals in terms of xvar to X in the model
    aliasNames = {}; % {'v', 'H'};
    aliasValues = {}; % {'a*b', [1:20]};
    xvar   = {}; % Cell-array with x-variable(s)
    xvals  = {}; % Cell-array of double-values for the different x-variable(s)
    xunits = unit; % vector of units of the different x-axis
    yunits = unit; % units of the y-axis
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    %--- trans
    function set.trans(obj, val)
      if isempty(val)
        if ~isempty(obj.trans)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'trans')).DefaultValue;
          obj.trans = dv;
        end
      elseif iscell(val)
        obj.trans = val;
      elseif ischar(val)
        obj.trans = {val};
      elseif isnumeric(val)
        obj.trans = {num2str(val)};
      else
        error('### The value for the property ''trans'' must be a cell-array. But it is from class [%s]', class(val));
      end
    end
    %--- expr
    function set.expr(obj, val)
      if ischar(val)
        obj.expr = msym(val);
      elseif isa(val, 'msym')
        obj.expr = val;
      else
        error('### The value for the property ''expr'' must be a MSYM object. But it is from class [%s]', class(val));
      end
    end
    %--- params
    function set.params(obj, val)
      if isempty(val)
        if ~isempty(obj.params)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'params')).DefaultValue;
          obj.params = dv;
        end
      elseif iscellstr(val)
        obj.params = val;
      elseif ischar(val)
        obj.params = cellstr(val);
      else
        error('### The value for the property ''params'' must be a cell of strings. But it is from class [%s]', class(val));
      end
    end
    %--- values
    function set.values(obj, val)
      if iscell(val)
        obj.values = val;
      elseif isnumeric(val)
        obj.values = num2cell(reshape(val, 1, []));
      else
        error('### The value for the property ''values'' must be a cell of numbers. But it is from class [%s]', class(val));
      end
    end
    %--- aliasNames
    function set.aliasNames(obj, val)
      if isempty(val)
        if ~isempty(obj.aliasNames)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'aliasNames')).DefaultValue;
          obj.aliasNames = dv;
        end
      elseif ischar(val)
        obj.aliasNames = cellstr(val);
      elseif iscell(val)
        obj.aliasNames = val;
      else
        error('### The value for the property ''aliasNames'' must be a cell of strings. But it is from class [%s]', class(val));
      end
    end
    %--- aliasValues
    function set.aliasValues(obj, val)
      if isempty(val)
        if ~isempty(obj.aliasValues)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'aliasValues')).DefaultValue;
          obj.aliasValues = dv;
        end
      elseif isnumeric(val)
        obj.aliasValues = num2cell(reshape(val, 1, []));
      elseif ischar(val)
        obj.aliasValues = cellstr(val);
      elseif isa(val,'smodel')
        obj.aliasValues = cell(val);
      elseif iscell(val)
        obj.aliasValues = val;
      else
        error('### The value for the property ''values'' must be a cell of numbers, strings or smodels. But it is from class [%s]', class(val));
      end
    end
    %--- xvar
    function set.xvar(obj, val)
      % Convert a string into a cell-array. This is necessary for backwards compatibility
      if isempty(val)
        if ~isempty(obj.xvar)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'xvar')).DefaultValue;
          obj.xvar = dv;
        end
      elseif iscell(val)
        obj.xvar = val;
      elseif ischar(val)
        obj.xvar = cellstr(val);
      else
        error('### The value for the property ''xvar'' must be a string or a cell array of strings. But it is from class [%s]', class(val));
      end
    end
    %--- xvals
    function set.xvals(obj, val)
      % Convert the value into a cell-array. This is necessary for backwards compatibility
      if isempty(val)
        if ~isempty(obj.xvals)
          % Get the default value of the property from the meta data
          m = metaclass(obj);
          p = [m.Properties{:}];
          dv = p(strcmp({p(:).Name}, 'xvals')).DefaultValue;
          obj.xvals = dv;
        end
      elseif iscell(val)
        obj.xvals = val;
      elseif isnumeric(val)
        obj.xvals = {val};
      elseif isa(val, 'ao')
        obj.xvals = {val.data.y};
      else
        error('### The value for the property ''xvals'' must be a cell-array. But it is from class [%s]', class(val));
      end
    end
    %--- xunits
    function set.xunits(obj, val)
      switch class(val)
        case 'char'
          obj.xunits = unit(val);
        case 'unit'
          obj.xunits = val;
        case 'cell'
          obj.xunits = unit(val{:});
        otherwise
          error('### The value for the property ''xunits'' must be a array of unit-object(s)');
      end
    end
    %--- yunits
    function set.yunits(obj, val)
      if ischar(val)
        obj.yunits = unit(val);
      elseif isa(val, 'unit')
        obj.yunits = val;
      else
        error('### The value for the property ''yunits'' must be a unit-object or a string');
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = smodel(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all smodel objects
      [mdls, ~, rest] = utils.helper.collect_objects(varargin(:), 'smodel');
      
      if isempty(rest) && ~isempty(mdls)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(mdls, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(smodel.getInfo('smodel', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%*
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(smodel.getInfo('smodel', 'None'), smodel.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   One input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   mdl = smodel('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   mdl = smodel('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   mdl = smodel('foo.mu')                   %%%%%%%%%%
            %%%%%%%%%%   mdl = smodel({'foo1.mat', 'foo2.mat'})   %%%%%%%%%%
            
            if iscell(varargin{1})
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
              obj = obj.fromFile(varargin{1});
            else
              % Is this a file?
              [~, ~, ext] = fileparts(varargin{1});
              
              if ismember(ext, {'.xml', '.mat', '.txt', '.dat', '.fil'})
                utils.helper.msg(msg.OPROC1, 'constructing from file %s', varargin{1});
                obj = obj.fromFile(varargin{1});
              else
                obj = obj.fromExpression(plist('expression', varargin{1}));
              end
            end
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   mdl = smodel(123)   %%%%%%%%%%
            obj = obj.fromExpression(plist('expression', varargin{1}));
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   mdl = smodel(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = obj.fromStruct(varargin{1});
            
          elseif isa(varargin{1}, 'sym')
            %%%%%%%%%%   mdl = smodel(symbolic-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from symbol');
            obj = obj.fromSymbol(plist('symbol', varargin{1}));
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  mdl = smodel(plist-object)   %%%%%%%%%%
            
            pl = varargin{1};
            
            if pl.isparam_core('expression')
              utils.helper.msg(msg.OPROC1, 'constructing from expression');
              obj = obj.fromExpression(pl);
              
            elseif pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from filename [%s]', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = obj.fromFile(pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              pl = applyDefaults(smodel.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(smodel.getInfo('smodel', 'None'), pl, [], []);
            end
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  mdl = smodel(<database-object>, [IDs])   %%%%%%%%%%
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   smodel('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isa(varargin{1}, 'smodel') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = smodel(smodel, <empty-plist>)   %%%%%%%%%%
            obj = smodel(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = smodel(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   smodel(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = smodel(varargin{2});
              else
                obj = smodel(varargin{1});
              end
            else
              obj = smodel(varargin{2});
            end
          else
            error('### Unknown 2 argument constructor.');
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   smodel('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [mdls, ~, rest] = utils.helper.collect_objects(varargin, 'smodel');
            
            %%% Do we have a list of smodels as input
            if ~isempty(mdls) && isempty(rest)
              obj = smodel(mdls);
            else
              error('### Unknown number of arguments.');
            end
          end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
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
      out = [SETS@ltpda_uoh, ...
        {'From Expression'}, ...
        {'From ASCII File'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = smodel.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = smodel.newarray([varargin{:}]);
    end
    
  end % End static methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromDatafile(varargin)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (protected, static)                       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(smodel.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = smodel.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from expression'
          
          % Expression
          p = param({'expression','Expression of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Params
          p = param({'params','Parameters which are used in the model.'}, {1, {{}}, paramValue.OPTIONAL});
          out.append(p);
          
          % Values
          p = param({'values','Default values for the parameters.'}, {1, {{}}, paramValue.OPTIONAL});
          out.append(p);
          
          % Xvar
          p = param({'xvar','The X-dependent variable.'},  paramValue.EMPTY_STRING);
          out.append(p);
          
          % Xvals
          p = param({'xvals','Values for the x-variable.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          % Yunits
          p = param({'yunits','Units of the y output.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Units of the x output.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from ascii file'
          
          % Filename
          p = param({'filename','ASCII filename.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Xvals
          p = param({'xvals','Values for the x-variable.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          % Yunits
          p = param({'yunits','Units of the y output.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Units of the x output.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = private)
    varargout = fromExpression(varargin)
    varargout = sop(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    varargout = elementOp(varargin)
    varargout = mergeFields(varargin)
  end
  
end % End classdef

