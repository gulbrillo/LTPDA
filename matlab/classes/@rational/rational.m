% RATIONAL rational representation of a transfer function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RATIONAL rational representation of a transfer function.
%
%           a(1)s^m + a(2)s^{m-1} + ... + a(m+1)
%   H(s) = --------------------------------------
%           b(1)s^n + b(2)s^{n-1} + ... + b(n+1)
%
% CONSTRUCTOR:
%
%       r = rational()                 - creates an empty rational object
%       r = rational(nun, den)         - construct from numerator and
%                                        denominator coefficients
%       r = rational(num, den, 'name') - construct including name
%       r = rational(num, den,         - construct from num, den, and io-units
%                    iunits, ounits)
%       r = rational(pl)               - create a rational object from the
%                                        description given in the parameter list.
%       r = rational(pzm)              - convert the TF described by the
%                                        pzmodel into a rational TF.
%
% Example constructor plists:
%
% Example: plist('filename', 'rational1.xml')
% Example: plist('filename', 'rational1.mat')
% Example: pzm = pzmodel(1, {1 2 3}, {4 5})
%          plist('pzmodel', pzm)
%
% <a href="matlab:utils.helper.displayMethodInfo('rational', 'rational')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef rational < ltpda_tf
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    num = []; % numerator coefficients [a]
    den = []; % denominator coefficients [b]
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.num(obj, val)
      if ~isnumeric(val) && ~isempty(val)
        error('### The value for the property ''num'' must be a numeric array.');
      end
      obj.num = val;
    end
    function set.den(obj, val)
      if ~isnumeric(val) && ~isempty(val)
        error('### The value for the property ''den'' must be a numeric array.');
      end
      obj.den = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = rational(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all pzmodel objects
      [rationals, ~, rest] = utils.helper.collect_objects(varargin(:), 'rational');
      
      if isempty(rest) && ~isempty(rationals)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(rationals, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(rational.getInfo('rational', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Zero inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(rational.getInfo('rational', 'None'), rational.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% One inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   pzm = pzmodel('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = pzmodel('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = pzmodel({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   r = rational(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'pzmodel')
            %%%%%%%%%%   r = rational(pzm)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel');
            pl = plist('pzmodel', varargin{1});
            obj = fromPzmodel(obj, pl);
            
          elseif isa(varargin{1}, 'parfrac')
            %%%%%%%%%%   r = rational(pf)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from parfrac');
            pl = plist('parfrac', varargin{1});
            obj = fromParfrac(obj, pl);
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   r = rational(plist)   %%%%%%%%%%
            pl = varargin{1};
            
            % Selection of construction method
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('num') || pl.isparam_core('den')
              utils.helper.msg(msg.OPROC1, 'constructing from coefficients');
              obj = fromCoefficients(obj, pl);
              
            elseif pl.isparam_core('pzmodel')
              utils.helper.msg(msg.OPROC1, 'constructing from pole/zero model');
              obj = fromPzmodel(obj, pl);
              
            elseif pl.isparam_core('parfrac')
              utils.helper.msg(msg.OPROC1, 'constructing from parfrac object');
              obj = fromParfrac(obj, pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              pl = applyDefaults(rational.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(rational.getInfo('rational', 'None'), pl, [], []);
            end
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%% Two inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  f = rational(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   rational('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(varargin{1}) && isnumeric(varargin{2})
            %%%%%%%%%  f = rational(num,den) %%%%%%%%%
            obj = fromCoefficients(obj, plist('num', varargin{1}, 'den', varargin{2}));
            
          elseif isa(varargin{1}, 'rational') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            % pass to copy constructor
            obj = rational(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = rational(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   rational(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = rational(varargin{2});
              else
                obj = rational(varargin{1});
              end
            else
              obj = rational(varargin{2});
            end
          else
            error('### Unknown 2 argument constructor.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Three inputs %%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   rational('to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   r = rational(num, den, name)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from coefficients');
            pl = plist('num', varargin{1}, 'den', varargin{2}, 'name', varargin{3});
            obj = fromCoefficients(obj, pl);
          end
          
        case 4
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Four inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   rational('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   pzm = rational(num, den, iunits, ounits)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from coefficients');
            pl = plist('num', varargin{1}, 'den', varargin{2}, 'iunits', varargin{3}, 'ounits', varargin{4});
            obj = fromCoefficients(obj, pl);
          end
          
        case 5
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% five inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%   pzm = rational(num, den, name, iunits, ounits)   %%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   rational('long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            utils.helper.msg(msg.OPROC1, 'constructing from coefficients');
            pl = plist('num', varargin{1}, 'den', varargin{2}, 'name', varargin{3}, 'iunits', varargin{4}, 'ounits', varargin{5});
            obj = fromCoefficients(obj, pl);
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   rational('very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [rationals, ~, rest] = utils.helper.collect_objects(varargin, 'rational');
            
            %%% Do we have a list of RATIONAL objects as input
            if ~isempty(rationals) && isempty(rest)
              obj = rational(rationals);
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
      out = [SETS@ltpda_uoh,   ...
        {'From Pzmodel'},      ...
        {'From Coefficients'}, ...
        {'From Parfrac'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = rational.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = rational.newarray([varargin{:}]);
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
      
      if ~utils.helper.ismember(lower(rational.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = rational.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from pzmodel'
          % pzmodel
          p = param({'pzmodel','Construct from a pole/zero model.'}, {1, {pzmodel}, paramValue.OPTIONAL});
          out.append(p);
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from parfrac'
          % parfrac
          p = param({'parfrac','Construct from a partial fraction model.'}, {1, {parfrac}, paramValue.OPTIONAL});
          out.append(p);
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from coefficients'
          % Num
          p = param({'num','Vector of coefficients.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Den
          p = param({'den','Vector of coefficients.'}, paramValue.EMPTY_DOUBLE);
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
    varargout = fromCoefficients(varargin)
    varargout = fromPzmodel(varargin)
    varargout = fromParfrac(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end % End classdef

