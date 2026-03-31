% PARFRAC partial fraction representation of a transfer function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARFRAC partial fraction representation of a transfer function.
%
%                 R(1)       R(2)             R(n)
%      H(s)  =  -------- + -------- + ... + -------- + K(s)
%               s - P(1)   s - P(2)         s - P(n)
%
% SUPER CLASSES: ltpda_tf < ltpda_uoh < ltpda_uo < ltpda_obj
%
% CONSTRUCTOR:
%
%       r = parfrac()                    - creates an empty parfrac object
%       r = parfrac(res, poles, dir)     - construct from residuals, poles
%                                          and direct terms
%       r = parfrac(..., 'name')         - construct including name
%       r = parfrac(..., iunits, ounits) - include input and output units
%       r = parfrac(pl)                  - create a parfrac object from the
%                                          description given in the parameter list.
%       r = parfrac(pzm)                 - create a parfrac from a pzmodel.
%       r = parfrac(rat)                 - create a parfrac from a rational TF.
%
%
% The poles can be specified in a array or a cell as a real or complex number.
%
% Example:  r = parfrac([1 2+1i 2-1i], [6 1+3i 1-3i], []);
%
% <a href="matlab:utils.helper.displayMethodInfo('parfrac', 'parfrac')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef parfrac < ltpda_tf
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    res   = []; % residuals [R]
    poles = []; % poles (real or complex numbers) [P]
    pmul = []; % Represents the pole multiplicity
    dir   = 0; % direct terms [K]
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.res(obj, val)
      if ~isnumeric(val) && ~isempty(val)
        error('### The value for the property ''res'' must be a numeric array.');
      end
      if size(val,1) == 1
        val = val.';
      end
      obj.res = val;
    end
    function set.poles(obj, val)
      if ~(isnumeric(val) || iscell(val)) && ~isempty(val)
        error('### The value for the property ''poles'' must be a numeric array.');
      end
      if size(val,1) == 1
        val = val.';
      end
      obj.poles = val;
    end
    function set.dir(obj, val)
      if ~isnumeric(val) && ~isempty(val)
        error('### The value for the property ''dir'' must be a numeric array.');
      end
      if isempty(val)
        obj.dir = val;
      end
      if size(val,1) == 1
        val = val.';
      end
      obj.dir = val;
    end
    function set.pmul(obj, val)
      if ~isnumeric(val) && ~isempty(val)
        error('### The value for the property ''pmul'' must be a numeric array.');
      end
      if size(val,1) == 1
        val = val.';
      end
      obj.pmul = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = parfrac(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all parfract objects
      [parfracs, ~, rest] = utils.helper.collect_objects(varargin(:), 'parfrac');
      
      if isempty(rest) && ~isempty(parfracs)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(parfracs, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(parfrac.getInfo('parfrac', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Zero inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(parfrac.getInfo('parfrac', 'None'), parfrac.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% One inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   pzm = parfract('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = parfract('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = parfract({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   r = parfrac(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'rational')
            %%%%%%%%%%   r = parfrac(rational-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from rational');
            obj = fromRational(obj, plist('rational', varargin{1}));
            
          elseif isa(varargin{1}, 'pzmodel')
            %%%%%%%%%%   r = parfrac(pzmodel-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel');
            obj = fromPzmodel(obj, plist('pzmodel', varargin{1}));
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   r = parfrac(plist)   %%%%%%%%%%
            pl       = varargin{1};
            
            % Selection of construction method
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('res') || pl.isparam_core('poles') || pl.isparam_core('dir')
              utils.helper.msg(msg.OPROC1, 'constructing from residuals/poles/direct');
              obj = fromResidualsPolesDirect(obj, pl);
              
            elseif pl.isparam_core('pzmodel')
              utils.helper.msg(msg.OPROC1, 'constructing from pole/zero model');
              obj = fromPzmodel(obj, pl);
              
            elseif pl.isparam_core('rational')
              utils.helper.msg(msg.OPROC1, 'constructing from rational object');
              obj = fromRational(obj, pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            elseif pl.isparam_core('Plist')
              ipl = find_core(pl, 'Plist');
              obj = parfrac(ipl);
              
            else
              pl = applyDefaults(parfrac.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(parfrac.getInfo('parfrac', 'None'), pl, [], []);
            end
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%% Two inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  f = parfrac(<database-object>, [IDs])   %%%%%%%%%%
            % parfrac(<database-object>, [IDs])
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif (isa(varargin{1}, 'parfrac') || isa(varargin{1}, 'rational')) && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = parfrac(parfrac-object, <empty plist>) %%%%%%%%%%
            obj = parfrac(varargin{1});
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   parfrac('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = parfrac(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   parfrac(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = parfrac(varargin{2});
              else
                obj = parfrac(varargin{1});
              end
            else
              obj = parfrac(varargin{2});
            end
          elseif isnumeric(varargin{1}) && isnumeric(varargin{2})
            % r = parfrac(num, den)
            utils.helper.msg(msg.OPROC1, 'constructing from residuals/poles/direct');
            pl = plist('res', varargin{1}, 'poles', varargin{2});
            obj = fromResidualsPolesDirect(obj, pl);
            
          else
            error('### Unknown 2 argument constructor.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Three inputs %%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   parfrac('to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   r = parfrac(num, den, dir)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from residuals/poles/direct');
            pl = plist('res', varargin{1}, 'poles', varargin{2}, 'dir', varargin{3});
            obj = fromResidualsPolesDirect(obj, pl);
          end
          
        case 4
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Four inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   parfrac('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   r = parfrac(num, den, dir, name)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from residuals/poles/direct');
            pl = plist('res', varargin{1}, 'poles', varargin{2}, 'dir', varargin{3}, 'name', varargin{4});
            obj = fromResidualsPolesDirect(obj, pl);
          end
          
        case 6
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% five inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   parfrac('very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   pzm = parfrac(res, poles, dir, name, iunits, ounits)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from residuals/poles/direct');
            pl = plist('res', varargin{1}, 'poles', varargin{2}, 'dir', varargin{3}, ...
              'name', varargin{4}, ...
              'iunits', varargin{5}, 'ounits', varargin{6});
            obj = fromResidualsPolesDirect(obj, pl);
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   parfrac('super', 'very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [parfracs, ~, rest] = utils.helper.collect_objects(varargin, 'parfrac');
            
            %%% Do we have a list of PARFRAC objects as input
            if ~isempty(parfracs) && isempty(rest)
              obj = parfrac(parfracs);
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
        {'From Rational'},   ...
        {'From Pzmodel'},    ...
        {'From Residuals/Poles/Direct'}];
    end
    
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = parfrac.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = parfrac.newarray([varargin{:}]);
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
    varargout = respCore(varargin)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(parfrac.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = parfrac.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      
      switch lower(set)
        case 'from rational'
          % rational
          p = param({'rational','Rational transfer-function model object to design from.'}, {1, {rational}, paramValue.OPTIONAL});
          out.append(p);
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
        case 'from pzmodel'
          % pzmodel
          p = param({'pzmodel','Pole/zero model object to design from.'}, {1, {pzmodel}, paramValue.OPTIONAL});
          out.append(p);
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
        case 'from residuals/poles/direct'
          
          % res
          p = param({'res','Residual terms.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Poles
          p = param({'poles','Poles (real or complex numbers).'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Dir
          p = param({'dir','Direct terms.'}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    varargout = fromResidualsPolesDirect(varargin)
    varargout = fromRational(varargin)
    varargout = fromPzmodel(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access=private, Static = true)
  end
  
end


