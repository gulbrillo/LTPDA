% MATRIX constructor for matrix class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MATRIX constructor for matrix class.
%
% CONSTRUCTOR:
%
%       fb = matrix()      - creates an empty matrix object
%       fb = matrix(objs)  - construct from an array of objects
%       fb = matrix(pl)    - create a matrix object from a parameter list
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'matrix')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef matrix < ltpda_container
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
    objs = []; % objects in matrix
  end
  
  properties (Dependent)
    size     % The size as a two element double array [nrows ncols]
    nrows    % The number of rows
    ncols    % The number of columns
    isvector % returns true or false
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function value = get.size(obj)
      value = size(obj.objs);
    end
    
    function value = get.nrows(obj)
      value = size(obj.objs, 1);
    end
    
    function value = get.ncols(obj)
      value = size(obj.objs, 2);
    end
    
    function value = get.isvector(obj)
      value = isvector(obj.objs);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = matrix(varargin)
      
      callerIsMethod = utils.helper.callerIsMethod;
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(matrix.getInfo('matrix', 'None'), matrix.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   pzm = matrix('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = matrix('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = matrix({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   r = matrix(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'collection')
            %%%%%%%%%%   r = matrix(collection)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from collection');
            c = varargin{1};
            for ii = 1:length(c)
              obj(ii) = matrix();
              if numel(unique(c(ii).objTypes)) > 1
                error('matrix/collection only works for collections of the same LTPDA data type');
              end
              for jj = 1:c(ii).nobjs
                cobjs(jj) = c(ii).getObjectAtIndex(jj);
              end
              obj(ii) = obj(ii).fromInput(plist('objs', cobjs), callerIsMethod);
              obj(ii).setName(sprintf('matrix(%s)',c(ii).name));
              obj(ii).setDescription(c(ii).description);
              clear cobjs
            end
          elseif isa(varargin{1}, 'ltpda_uoh')
            %%%%%%%%%%   r = matrix(<ltpda_uoh-objects>)   %%%%%%%%%%
            obj = obj.fromInput(plist('objs', varargin), callerIsMethod);
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   r = matrix(doubleArray)   %%%%%%%%%%
            obj = obj.fromValues(plist('values', varargin{1}), callerIsMethod);
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   r = matrix(plist)   %%%%%%%%%%
            pl = varargin{1};
            
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.PROC2, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = obj.fromFile(pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.PROC2, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('objs')
              obj = obj.fromInput(pl, callerIsMethod);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            elseif pl.isparam_core('values')
              obj = obj.fromValues(pl, callerIsMethod);
              
            else
              pl = applyDefaults(matrix.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(matrix.getInfo('matrix', 'None'), pl, [], []);
            end
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'ltpda_uoh')
            %%%%%%%%%%  f = matrix(a1, a2)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromInput(plist('objs', varargin), callerIsMethod);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   matrix('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) ...
              && isnumeric(varargin{2})
            %%%%%%%%%%  f = matrix(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif isa(varargin{1}, 'matrix') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = matrix(matrix-object, <empty plist>) %%%%%%%%%%
            obj = matrix(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = matrix(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isnumeric(varargin{1}) && iscell(varargin{2})
            %%%%%%%%%%   r = matrix(doubleArray, cellArray)   %%%%%%%%%%
            obj = matrix(plist('values', varargin{1}, 'yunits', varargin{2}));
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   matrix(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist if it contains 'objs' key
            
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = matrix(varargin{2});
              else
                obj = matrix(varargin{1});
              end
            else
              if isparam_core(varargin{2}, 'objs')
                obj = matrix(varargin{2});
              else
                obj = obj.fromInput(combine(plist('objs', varargin{1}), varargin{2}), callerIsMethod);
              end
            end
          else
            error('### Unknown 2 argument constructor.');
          end
          
        otherwise
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   any input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   matrix('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [pls, ~, rest] = utils.helper.collect_objects(varargin, 'plist');
            pl = combine(plist('objs', rest), pls);
            
            obj = obj.fromInput(pl, callerIsMethod);
          end
      end
      
    end % End constructor
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    out       = det(varargin)
    out       = inv(varargin)
    varargout = minus(varargin)
    varargout = plus(varargin)
    varargout = rdivide(varargin)
    varargout = times(varargin)
    varargout = mtimes(varargin)
    varargout = transpose(varargin)
    varargout = ctranspose(varargin)
    varargout = filter(varargin)
    varargout = osize(varargin)
    varargout = setObjs(varargin)
    varargout = getObjectAtIndex(varargin)
    varargout = mchNoisegen(varargin)
    varargout = mchNoisegenFilter(varargin)
    varargout = loglikelihood(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    varargout = loglikelihood_core(varargin)
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
        {'From Input'},  ...
        {'From Values'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = matrix.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = matrix.newarray([varargin{:}]);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (protected)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromInput(varargin)
    varargout = fromStruct(varargin)
    varargout = clearObjHistories(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(matrix.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = matrix.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from input'
          p = param({'shape', 'Specify the shape of the resulting matrix.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          p = param({'objs', 'Matrix of user objects.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
        case 'from values'
          
          % Values
          p = param({'values', 'Each value will create a single AO.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Yunits
          p = param({'yunits', 'Y-unit for the AOs which are built from the values'}, paramValue.EMPTY_CELL);
          out.append(p);
          
          % Names
          p = param({'names', 'Names for the AOs which are built from the values'}, paramValue.EMPTY_CELL);
          out.append(p);
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    varargout = fromValues(varargin)
    varargout = xspec(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    varargout = elementOp(varargin)
  end
  
end
