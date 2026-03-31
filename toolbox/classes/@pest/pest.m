% PEST constructor for parameter estimates (pest) class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PEST constructor for parameter estimates (pest) class.
%
% CONSTRUCTOR:
%
%       pe = pest()
%       pe = pest(filename)
%       pe = pest(plist-object)
%       pe = pest(y, paramNames)
%       pe = pest(y, paramNames, dy)
%       pe = pest(y, paramNames, dy, cov)
%       pe = pest(y, paramNames, dy, cov, chi2)
%       pe = pest(y, paramNames, dy, cov, chi2, dof)
%
% INPUTS:
%
%       y          - best fit parameters
%       paramNames - names of the parameters
%       dy         - standard errors of the parameters
%       cov        - covariance matrix of the parameters
%       chi2       - reduced chi^2 of the final fit
%       dof        - degrees of freedom
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'pest')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef pest < ltpda_uoh
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
    dy     = [];      % standard errors of the parameters.
    y      = [];      % best fit parameters
    names  = {};      % names of the parameters, if any
    yunits = unit.initObjectWithSize(1,0);  % the units of each parameter
    pdf    = [];      % posterior probability distribution of the parameters
    cov    = [];      % covariance matrix of the parameters
    corr   = [];      % correlation matrix of the parameters
    chi2   = [];      % reduced chi^2 of the final fit
    dof    = [];      % degrees of freedom
    chain  = [];      % monte carlo markov chain
    models = [];      % models that were fit
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    % y
    function set.y(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || (~isvector(val) && ~isempty(val))
        error('### The value for the property ''y'' must be a numeric vector');
      end
      if ~isempty(val)
        obj.y = reshape(val, [], 1);
      else
        obj.y = val;
      end
    end
    % dy
    function set.dy(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || (~isvector(val) && ~isempty(val))
        error('### The value for the property ''dy'' must be a numeric vector');
      end
      if ~isempty(val)
        obj.dy = reshape(val, [], 1);
      else
        obj.dy = val;
      end
    end
    % names
    function set.names(obj, val)
      if numel(val) == 1 && iscell(val{1})
        vals = val{1};
        for kk=1:numel(vals)
          vals{kk} = char(vals{kk});
        end
        val = vals;
      end
      if isempty(val)
        val = {};
      end
      if ~(iscell(val) || ischar(val))
        error('### The value for the property ''names'' must be a cell of parameter names.');
      end
      if iscell(val)
        for kk=1:numel(val)
          val{kk} = char(val{kk});
        end
        obj.names = val;
      else
        obj.names = cellstr(val);
      end
      if ~isempty(obj.names)
        obj.names = reshape(obj.names, 1, []);
      end
    end
    % yunits
    function set.yunits(obj, val)
      if numel(val) == 1 && iscell(val) && iscell(val{1})
        val = val{1};
      end
      if isempty(val)
        obj.yunits = unit.initObjectWithSize(size(val,1), size(val,2));
      elseif ischar(val)
        obj.yunits = unit(val);
      elseif isa(val, 'unit')
        obj.yunits = copy(val,1);
      elseif iscell(val)
        obj.yunits = unit(val{:});
      else
        error('### The yunits value must be a vector of unit-objects or a string');
      end
    end
    % pdf
    function set.pdf(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || ndims(val) ~= 2
        error('### The value for the property ''pdf'' must be a numeric matrix');
      end
      obj.pdf = val;
    end
    % cov
    function set.cov(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || ndims(val) ~= 2
        error('### The value for the property ''Cov'' must be a numeric matrix');
      end
      obj.cov = val;
    end
    % corr
    function set.corr(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || ndims(val) ~= 2
        error('### The value for the property ''Corr'' must be a numeric matrix');
      end
      obj.corr = val;
    end
    % chi2
    function set.chi2(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || (any(size(val) ~= [1 1]) && ~isempty(val))
        error('### The value for the property ''chi2'' must be a single double');
      end
      obj.chi2 = val;
    end
    % dof
    function set.dof(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val) || (any(size(val) ~= [1 1]) && ~isempty(val))
        error('### The value for the property ''dof'' must be a single double');
      end
      obj.dof = val;
    end
    % dof
    function set.chain(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~isnumeric(val)
        error('### The value for the property ''chain'' must be a double');
      end
      obj.chain = val;
    end
    
    % models
    function set.models(obj, val)
      try
        % The genericSet method sets the value with a cell-array
        val = [val{:}];
      end
      if ~(isa(val, 'ltpda_uoh') || isempty(val))
        error('### The value for the property ''models'' must be ltpda_uoh object');
      end
      if ~isempty(val)
        obj.models = val;
      else
        obj.models = [];
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                     Compute the Dependent properties                      %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = pest(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all pest objects
      [objs, ~, rest] = utils.helper.collect_objects(varargin(:), 'pest');
      
      if isempty(rest) && ~isempty(objs)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(objs, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(pest.getInfo('pest', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%*
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(pest.getInfo('pest', 'None'), pest.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   One input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   obj = pest('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   obj = pest('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   obj = pest({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   obj = pest(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = obj.fromStruct(varargin{1});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  obj = pest(plist-object)   %%%%%%%%%%
            
            pl = varargin{1};
            
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            elseif pl.isparam_core('y')
              utils.helper.msg(msg.OPROC1, 'constructing from values');
              obj = obj.fromValues(pl);
              
            elseif pl.isparam_core('aos')
              utils.helper.msg(msg.OPROC1, 'constructing from AOs');
              obj = obj.fromAOs(pl);
              
            else
              pl = applyDefaults(pest.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(pest.getInfo('pest', 'None'), pl, [], []);
            end
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   obj = pest(y)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y');
            pl = plist('y', varargin{1});
            obj.fromValues(pl);
            
          elseif isa(varargin{1}, 'ao')
            %%%%%%%%%%   obj = pest(y)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from AOs');
            pl = plist('aos', varargin{1});
            obj.fromAOs(pl);
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  obj = pest(<database-object>, [IDs])   %%%%%%%%%%
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pest('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(varargin{1}) && (isobject(varargin{2}) || iscell(varargin{2}) || ischar(varargin{2}))
            %%%%%%%%%%   obj = pest(y, paramNames)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y and param names');
            
            names = varargin{2};
            if isobject(names)
              names = char(names);
            end
            
            pl = plist('y', varargin{1}, 'paramNames', names);
            obj.fromValues(pl);
            
          elseif isa(varargin{1}, 'pest') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  obj = pest(pest, <empty-plist>)   %%%%%%%%%%
            obj = pest(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = pest(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   obj = pest(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = pest(varargin{2});
              else
                obj = pest(varargin{1});
              end
            else
              obj = pest(varargin{2});
            end
            
          else
            error('### Unknown 2 argument constructor.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isnumeric(varargin{1})                       && ...
              (iscell(varargin{2}) || ischar(varargin{2})) && ...
              isnumeric(varargin{3})
            %%%%%%%%%%   obj = pest(y, paramNames, dy)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y, param names and dy');
            pl = plist(...
              'y',          varargin{1}, ...
              'paramNames', varargin{2}, ...
              'dy',         varargin{3});
            obj.fromValues(pl);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pest('to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown 3 argument constructor.');
          end
          
        case 4
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   four inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isnumeric(varargin{1})                       && ...
              (iscell(varargin{2}) || ischar(varargin{2})) && ...
              isnumeric(varargin{3})                       && ...
              isnumeric(varargin{4})
            %%%%%%%%%%   obj = pest(y, paramNames, dy)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y, param names, dy and cov');
            pl = plist(...
              'y',          varargin{1}, ...
              'paramNames', varargin{2}, ...
              'dy',         varargin{3}, ...
              'cov',        varargin{4});
            obj.fromValues(pl);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pest('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown 4 argument constructor.');
          end
          
        case 5
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   five inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isnumeric(varargin{1})                       && ...
              (iscell(varargin{2}) || ischar(varargin{2})) && ...
              isnumeric(varargin{3})                       && ...
              isnumeric(varargin{4})                       && ...
              isnumeric(varargin{5})
            %%%%%%%%%%   obj = pest(y, paramNames, dy)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y, param names, dy, cov and chi2');
            pl = plist(...
              'y',          varargin{1}, ...
              'paramNames', varargin{2}, ...
              'dy',         varargin{3}, ...
              'cov',        varargin{4}, ...
              'chi2',       varargin{5});
            obj.fromValues(pl);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pest('long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown 5 argument constructor.');
          end
          
        case 6
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   six inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isnumeric(varargin{1})                       && ...
              (iscell(varargin{2}) || ischar(varargin{2})) && ...
              isnumeric(varargin{3})                       && ...
              isnumeric(varargin{4})                       && ...
              isnumeric(varargin{5})                       && ...
              isnumeric(varargin{6})
            %%%%%%%%%%   obj = pest(y, paramNames, dy)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from y, param names, dy, cov, chi2 and dof');
            pl = plist(...
              'y',          varargin{1}, ...
              'paramNames', varargin{2}, ...
              'dy',         varargin{3}, ...
              'cov',        varargin{4}, ...
              'chi2',       varargin{5}, ...
              'dof',        varargin{6});
            obj.fromValues(pl);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pest('very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown 6 argument constructor.');
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   pest('super', 'very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [pObjs, ~, rest] = utils.helper.collect_objects(args, 'pest');
            
            %%% Do we have a list of PEST objects as input
            if ~isempty(pObjs) && isempty(rest)
              obj = pest(pObjs);
            else
              error('### Unknown number of arguments.');
            end
          end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods  (public)                             %
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
      out = [SETS@ltpda_uoh, {'From Values', 'From AOs'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = pest.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = pest.newarray([varargin{:}]);
    end
    
  end % End static methods
  
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
    varargout = fromValues(varargin)
    varargout = fromAOs(varargin)
    varargout = genericSet(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(pest.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = pest.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from aos'
          p = param({'aos', 'Analysis object with a single cdata value'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
        case 'from values'
          % y
          p = param({'y','Best fit parameters'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % parameter names
          p = param({'paramNames','Names of the parameters'}, paramValue.EMPTY_CELL);
          p.addAlternativeKey('names');
          p.addAlternativeKey('params');
          out.append(p);
          % dy
          p = param({'dy','Standard errors of the parameters'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % cov
          p = param({'cov','Covariance matrix of the parameters'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % corr
          p = param({'corr','Correlation matrix of the parameters'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % chi2
          p = param({'chi2','Reduced chi^2 of the final fit'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % chain
          p = param({'chain','Monte carlo markov chain'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % dof
          p = param({'dof','Degrees of freedom'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % models
          p = param({'models',['Models used for the fit in which the coefficients were calculated<br>' ...
            'Please notice that the models need to be stored in a <tt>smodel</tt> object!']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % pdf
          p = param({'pdf','Probability density function, as output by MCMC methods'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          % yunits
          p = param({'yunits','A cell-array of units for the parameters.'}, paramValue.EMPTY_CELL);
          out.append(p);
          
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end
