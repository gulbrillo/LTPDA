% MFH function handle class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFH function handle class constructor.
%
%     Possible constructors:
%          f = mfh(pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'mfh')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef mfh < ltpda_uoh
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    
    func         = '';  % @()(func) String of the function
    subfuncs     = [];  % Array of mfh objects with the sub functions
    inputs       = {};  % @(inputs)()
    inputObjects = {};  % Cell array with any type of objects
    constants    = {};  % Cell array with strings of the constant names
    constObjects = {};  % Cell array with any type of objects for the constants
    
    funcDef   = '';    % definition expression
    paramsDef = [];    % parameter definition
    numeric   = false;
  end
  
  properties (SetAccess = private, Transient=true)
    
    % these are to be treated as transient properties and don't need to be
    % saved or copied
    funcHandle   = []; % The handle of the function which is described in 'func'
  end
  

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function set.constants(obj, val)
      
      obj.constants = mfh.prepareConstants(val);
  
    end
    
    
    function set.paramsDef(obj, val)
      if ~isempty(val) && ~isa(val, 'pest')
        error('### The value for the property ''paramsDef'' must be a pest');
      end
      obj.paramsDef = val;
    end
    
    function set.func(obj, val)
      if ~isempty(val) && ~ischar(val)
        error('### The value for the property ''func'' must be a string');
      end
      obj.func = val;
    end

    function set.funcDef(obj, val)
      if ~isempty(val) && ~ischar(val)
        error('### The value for the property ''funcDef'' must be a string');
      end
      obj.funcDef = val;
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    
    function obj = mfh(varargin)
      
      import utils.const.*
      % Collect all mfh objects
      [mfhs, ~, rest] = utils.helper.collect_objects(varargin(:), 'mfh');
      
      if isempty(rest) && ~isempty(mfhs)
        %%%%%%%%%%  Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(mfhs, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(mfh.getInfo('mfh', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      %%%%%%%%%%  Make sure that we always have a 'name'
      obj.name = sprintf('f%d', time().utc_epoch_milli);
      
      switch nargin
        
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(mfh.getInfo('mfh', 'None'), combine(plist('name', obj.name), mfh.getDefaultPlist('Default')), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%  obj = mfh('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%  obj = mfh('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%  obj = mfh({'foo1.mat', 'foo2.mat'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, plist('filename', varargin{1}, 'name', obj.name));
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  f = mfh(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  obj = mfh(plist-object)   %%%%%%%%%%
            
            pl = varargin{1};
            % Selection of construction method
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, combine(pl, plist('name', obj.name)));
              
            elseif pl.isparam_core('built-in')
              
              %--- Construct from model
              utils.helper.msg(msg.PROC2, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository');
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('func')
              
              utils.helper.msg(msg.OPROC1, 'constructing from plist. %s', pl.find_core('func'));
              pl = applyDefaults(mfh.getDefaultPlist('Default'), pl);
              
              obj.funcDef   = pl.find_core('func');
              p0 = pl.find_core('params');
              if ~isempty(p0)
                obj.paramsDef = copy(p0, 1);
              end
              obj.subfuncs  = pl.find_core('subfuncs');
              
              % The name is already set above.
              % Make only sure that we store the name in the history if the
              % user doesn't support a name.
              if isempty(pl.find_core('name'))
                pl.pset('name', obj.name);
              else
                obj.name = pl.find_core('name');
              end
              
              % set description
              obj.description = pl.find_core('description');
              
              % numeric
              obj.numeric = pl.find_core('numeric');
              
              % inputs
              obj.inputs = cellstr(pl.find_core('inputs'));
              obj.inputObjects = pl.find_core('inputObjects');
              if ~iscell(obj.inputObjects)
                % Make sure that the input objects are in a cell array
                obj.inputObjects = {obj.inputObjects};
              end
              
              % constants
              obj.constants = mfh.prepareConstants(pl.find_core('constants'));
              obj.constObjects = pl.find_core('constant objects');
              if ~iscell(obj.constObjects)
                % Make sure that the constant objects are in a cell array
                obj.constObjects = {obj.constObjects};
              end
              
              % add history for the constructor
              obj.addHistory(mfh.getInfo('mfh', 'None'), pl, [], []);
              
            else
              % build a mfh-object from the plist and default values
              pl = applyDefaults(mfh.getDefaultPlist('Default') , combine(pl, plist('name', obj.name)));
              obj.setObjectProperties(pl);
              obj.addHistory(mfh.getInfo('mfh', 'None'), pl, [], []);
            end
            
          else
            error('### Unknown 1 argument constructor. mfh(%s)', class(varargin{1}));
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = mfh(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   mfh('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown 2 argument constructor. mfh(%s,%s)', class(varargin{1}), class(varargin{2}));
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   mfh('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [mObjs, ~, rest] = utils.helper.collect_objects(args, 'mfh');
            
            %%% Do we have a list of MFH objects as input
            if ~isempty(mObjs) && isempty(rest)
              obj = mfh(mObjs);
            else
              error('### Unknown number of arguments.');
            end
          end
          
      end % END switch
      
      % apply the definition, if we have one
      for mm = 1:numel(obj)
        obj(mm).applyDef();
      end
    end % END constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods  (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    
    function resetCachedProperties(obj)
      obj.funcHandle = [];
    end
    
    function applyDef(obj)
      
      % loop through parameters in the input params def
      obj.func = obj.funcDef;
      if ~isempty(obj.paramsDef)
        if isempty(obj.paramsDef.name)
          error('The parameter definition pest has no name and so can''t be referenced in the model expression. Please give the input pest a name, and make sure this matches any reference to it in the model expression.');
        end
        pname = utils.helper.genvarname(obj.paramsDef.name);
        for kk=1:numel(obj.paramsDef.names)
          if strcmpi(obj.paramsDef.names{kk}, obj.paramsDef.name)
            error('A parameter name can not be equal to the name of the input pest object. Please choose another name of the input pest object.')
          end
          if strcmpi(obj.paramsDef.names{kk}, 'f')
            error('A parameter name can not be equal to ''f''. Please choose a different parameter name.')
          end
          p = obj.paramsDef.names{kk};
          if obj.numeric
            nname = sprintf('%s(%d)', pname, kk);
          else
            nname = sprintf('%s.find(''%s'')', pname, p);
          end
          
          % Replace in function string
          obj.func = strrep(obj.func, p, nname);
        end
        % set inputs
        obj.inputs = {pname};
      end
      
      % validate constants units
      for kk=1:numel(obj.constants)
        name = obj.constants{kk};
        val  = obj.constObjects{kk};
        if ~isempty(val) && isa(val, 'ao') && isa(name, 'LTPDANamedItem')
          if ~isempty(name.units) && ...
              ~isempty(val.yunits) && ...
              ~isequal(name.units.toSI, val.yunits.toSI)
            error('Units of constant data [%s] %s don''t match the definition for this constant %s', val.name, char(val.yunits), char(name.units));
          end
        end        
      end
      
    end % End applyDef    
    
    
    varargout = num2cell(varargin)
    varargout = subsref(varargin)
    varargout = declare_objects(varargin)
    varargout = loglikelihood_ao_td(varargin)
    varargout = loglikelihood_core(varargin)
    varargout = loglikelihood_core_td(varargin)
    varargout = loglikelihood_core_log(varargin)
    varargout = loglikelihood_core_noiseFit_v1(varargin)
    varargout = loglikelihood_core_student(varargin)
    varargout = loglikelihood_core_whittle(varargin)
    varargout = loglikelihood_hyper(varargin)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    function constants = prepareConstants(val)
      % PREPARECONSTANTS prepares the input constants (specified by char or
      % LTPDANamedItem subclasses, or a mix) to be used in a model.
      %
      
      
      if isempty(val)
        constants = {};
        return
      end
      
      if ischar(val)
        constants = {LTPDANamedItem(val)};
        return
      end
      
      if iscell(val)
        for vv=1:numel(val)
          if isa(val{vv}, 'LTPDANamedItem')
            % leave it alone
          elseif ischar(val{vv})
            if strcmpi(val{vv}, 'f')
              error('A constant name can not be equal to ''f''. Please choose a different constant name.')
            end
            val{vv} = LTPDANamedItem(val{vv});
          else
            error('Unknown data type [%s] for element %d of constants', class(val{vv}), vv);
          end
        end
        constants = val;
        return
      end
      
      if isa(val, 'LTPDANamedItem')
        cellvals = {};
        for kk=1:numel(val)
          cellvals = [cellvals {val(kk)}];
        end
        constants = cellvals;
        return
      end
      
      error('Unknown data type [%s] for constants', class(val));      
      
    end
    
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = mfh.newarray([varargin{:}]);
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function out = SETS()
      out = SETS@ltpda_uoh;
    end
    
    % Return the plist for a particular parameter set
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = mfh.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (protected, static)                       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(mfh.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = mfh.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'default'
          
          % func
          p = param({'func','The function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % subfuncs
          p = param({'subfuncs','Sub functions used in the expression.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % params
          p = param({'params','A pest object defining the parameters of the model and their units.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);          
          
          % numeric
          p = param({'numeric','Build the model to be evaluated in a purely numeric way. No ltpda objects involed. Essentially parameters will not be wrapped in unit operators if this is true.'}, paramValue.FALSE_TRUE);
          out.append(p);          
          
          % inputs
          p = param({'inputs','Input variable names.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          % inputobjects
          p = param({'inputObjects','Input objects to work on.'}, paramValue.EMPTY_CELL);
          p.addAlternativeKey('input Objects');
          out.append(p);
          
          % constants
          p = param({'constants','List of constant terms.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          % constant objects
          p = param({'constObjects','List of values/objects for the constant terms.'}, paramValue.EMPTY_CELL);
          p.addAlternativeKey('constant Objects');
          out.append(p);
          
      end
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (private)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    varargout = elementOp(varargin)
  end
  
end

