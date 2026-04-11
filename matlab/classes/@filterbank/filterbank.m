% FILTERBANK constructor for filterbank class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTERBANK constructor for filterbank class.
%
% CONSTRUCTOR:
%
%       fb = filterbank()                - creates an empty filterbank object
%       fb = filterbank(filters)         - construct from an array of filters
%       fb = filterbank(filters, plist)  - construct from an array of filters
%                                          Bank type is set in the plist
%
% <a href="matlab:utils.helper.displayMethodInfo('filterbank', 'filterbank')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef filterbank < ltpda_uoh
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    filters = []; % Filters of the bank
    type    = ''; % Type of the bank
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
    function obj = filterbank(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all filterbank objects
      [banks, ~, rest] = utils.helper.collect_objects(varargin(:), 'filterbank');
      
      if isempty(rest) && ~isempty(banks)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(banks, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(filterbank.getInfo('filterbank', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%*
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(filterbank.getInfo('filterbank', 'None'), filterbank.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   One input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   pzm = filterbank('foo.mat')                 %%%%%%%%%%
            %%%%%%%%%%   pzm = filterbank('foo.xml')                 %%%%%%%%%%
            %%%%%%%%%%   pzm = filterbank({'foo1.xml', 'foo2.xml')   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
          elseif isa(varargin{1}, 'miir') || isa(varargin{1}, 'mfir')
            
            obj = obj.fromFilters(plist('filters', varargin{1}));
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   mdl = filterbank(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = obj.fromStruct(varargin{1});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  mdl = filterbank(plist-object)   %%%%%%%%%%
            
            pl = varargin{1};
            
            if pl.isparam_core('filters')
              utils.helper.msg(msg.OPROC1, 'constructing from filters');
              obj = obj.fromFilters(pl);
            elseif pl.isparam_core('filename') || pl.isparam_core('filenames')
              %%%%%%%%%%  f = filterbank('foo.mat')   %%%%%%%%%%
              %%%%%%%%%%  f = filterbank('foo.xml')   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              pl = applyDefaults(filterbank.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(filterbank.getInfo('filterbank', 'None'), pl, [], []);
            end
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  mdl = filterbank(<database-object>, [IDs])   %%%%%%%%%%
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   filterbank('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isa(varargin{1}, 'filterbank') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = filterbank(filterbank, <empty-plist>)   %%%%%%%%%%
            obj = filterbank(varargin{1});
            
          elseif isa(varargin{1}, 'ltpda_filter') && ischar(varargin{2})
            %%%%%%%%%%  f = filterbank(filter-object, 'parallel')   %%%%%%%%%%
            
            obj = obj.fromFilters(plist('filters', varargin{1}, 'type', varargin{2}));
            
          elseif isa(varargin{1}, 'ltpda_filter') && isa(varargin{2}, 'plist')
            %%%%%%%%%%  f = filterbank(filter-object, plist-object)   %%%%%%%%%%
            
            obj = obj.fromFilters(combine(plist('filters', varargin{1}), varargin{2}));
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = filterbank(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   filterbank(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = filterbank(varargin{2});
              else
                obj = filterbank(varargin{1});
              end
            else
              obj = filterbank(varargin{2});
            end
          elseif isa(varargin{1}, 'ltpda_filter') && isa(varargin{2}, 'ltpda_filter')
            obj = obj.fromFilters(plist('filters', [varargin{:}]));
          else
            error('### Unknown 2 argument constructor.');
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   filterbank('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [filts, ~, rest] = utils.helper.collect_objects(varargin, 'ltpda_filter');
            
            %%% We provide a plist
            if numel(filts) > 0
              
              % put filters in a plist
              pl = plist('filters', filts);
              
              % check if there are additional plists given
              if ~isempty(rest) && isa(rest{1}, 'plist')
                pl = pl.combine(rest{1});
              end
              
              % build from filters
              obj = obj.fromFilters(pl);
              
              %%% We do not provide a plist
            elseif numel(filts) > 0 && (isempty(rest) || ~isa(rest{1}, 'plist'))
              obj = obj.fromFilters(plist('filters', filts));
            else
              [mdls, ~, rest] = utils.helper.collect_objects(varargin, 'filterbank');
              
              %%% Do we have a list of filterbanks as input
              if ~isempty(mdls) && isempty(rest)
                obj = filterbank(mdls);
              else
                error('### Unknown number of arguments.');
              end
            end
          end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = resp(varargin)
    varargout = setIunits(varargin)
    varargout = setOunits(varargin)
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
      out = [SETS@ltpda_uoh, {'From Filters'}];
    end
    
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = filterbank.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = filterbank.newarray([varargin{:}]);
    end
    
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
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (protected, static)                       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(filterbank.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = filterbank.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from filters'
          % Filters
          p = param({'filters','The array of MFIR or MIIR filter objects.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Type
          p = param({'type','The type of filter bank (parallel or serial).'}, {1, {'parallel', 'serial'}, paramValue.OPTIONAL});
          out.append(p);
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    varargout = fromFilters(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end


