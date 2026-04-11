% PZMODEL constructor for pzmodel class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PZMODEL constructor for pzmodel class.
%
%
% CONSTRUCTOR:
%
%       pzm = pzmodel()                - creates an empty pzmodel object
%       pzm = pzmodel(g, p, z)         - construct from gain, poles, zeros
%       pzm = pzmodel(g, p, z, d)      - construct from gain, poles, zeros and a delay (in seconds)
%       pzm = pzmodel(g, p, z, 'name') - construct including name
%       pzm = pzmodel(g, p, z,         - construct from gain, poles, zeros, and
%                     iunits, ounits)              io-units
%       pzm = pzmodel('foo.fil')       - construct from LISO .fil file
%       pzm = pzmodel('foo.xml')       - construct by loading the pzmodel from disk
%       pzm = pzmodel('foo.mat')       - construct by loading the pzmodel from disk
%       pzm = pzmodel(pl)              - create a pzmodel object from the
%                                        description given in the parameter list.
%       pzm = pzmodel(rat)             - creates a pzmodel from rational TF
%
%
% Poles and zeros can be given as single values, or a 2-element vector for
% [f, Q]. Multiple poles and zeros should be given in a cell-array:
%
% e.g. p = pzmodel(1, {1, 2, [3 4]}, {5, [6 10]}, 2)
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'pzmodel')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef pzmodel < ltpda_tf
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    poles   = []; % pole-array of the model
    zeros   = []; % zero-array of the model
    gain    = NaN; % gain of the model
    delay   = 0; % delay of the pole/zero model
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.gain(obj, val)
      if ~isnumeric(val) || isempty(val) || ~isreal(val)
        error('### The value for the property ''gain'' must be a real number');
      end
      obj.gain = val;
    end
    function set.poles(obj, val)
      if ~isa(val, 'pz') && ~isempty(val)
        error('### The value for the property ''poles'' must be a vector of pz objects.');
      end
      obj.poles = val;
    end
    function set.zeros(obj, val)
      if ~isa(val, 'pz') && ~isempty(val)
        error('### The value for the property ''zeros'' must be a vector of pz objects.');
      end
      obj.zeros = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = pzmodel(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % check if the caller was a user of another method
      callerIsMethod = utils.helper.callerIsMethod;
      
      % Collect all pzmodel objects
      if nargin > 0 && isa(varargin{1}, 'pzmodel')
        [pzs, ~, rest] = utils.helper.collect_objects(varargin(:), 'pzmodel');
        
        if isempty(rest) && ~isempty(pzs)
          % Do copy constructor and return
          utils.helper.msg(msg.OPROC1, 'copy constructor');
          obj = copy(pzs, 1);
          if ~callerIsMethod
            for kk=1:numel(obj)
              obj(kk).addHistory(pzmodel.getInfo('pzmodel', 'None'), [], [], obj(kk).hist);
            end
          end
          return
        end
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Zero inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          if ~callerIsMethod
            obj.addHistory(pzmodel.getInfo('pzmodel', 'None'), pzmodel.getDefaultPlist('Default'), [], []);
          end
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% One inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%   pzm = pzmodel('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = pzmodel('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = pzmodel('foo.fil')                  %%%%%%%%%%
            %%%%%%%%%%   pzm = pzmodel({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isnumeric(varargin{1})
            %%%%%%%%% pzm = pzmodel(const) %%%%%%%%%%%%%%
            
            if callerIsMethod
              obj.gain =  varargin{1};
            else
              obj = fromPolesAndZeros(obj, plist('gain', varargin{1}), callerIsMethod);
            end
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   pzm = pzmodel(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'rational')
            %%%%%%%%%%   pzm = pzmodel(rational-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from rational');
            obj = fromRational(obj, plist('rational', varargin{1}));
            
          elseif isa(varargin{1}, 'parfrac')
            %%%%%%%%%%   pzm = pzmodel(rational-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from parfrac');
            obj = fromParfrac(obj, plist('parfrac', varargin{1}));
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   pzm = pzmodel(plist-object)   %%%%%%%%%%
            pl = varargin{1};
            
            if pl.isparam_core('gain') || pl.isparam_core('poles') || pl.isparam_core('zeros')
              utils.helper.msg(msg.OPROC1, 'constructing from poles and zeros');
              obj = fromPolesAndZeros(obj, pl, callerIsMethod);
              
            elseif pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('rational')
              utils.helper.msg(msg.OPROC1, 'constructing from rational object');
              obj = fromRational(obj, pl);
              
            elseif pl.isparam_core('parfrac')
              utils.helper.msg(msg.OPROC1, 'constructing from parfrac');
              obj = fromParfrac(obj, pl);
              
            elseif pl.isparam_core('pzmodel')
              utils.helper.msg(msg.OPROC1, 'constructing from pole/zero model');
              obj = pzmodel(find_core(pl, 'pzmodel'));
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              pl = applyDefaults(pzmodel.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(pzmodel.getInfo('pzmodel', 'None'), pl, [], []);
            end
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%% Two inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isnumeric(varargin{1}) && isnumeric(varargin{2})
            %%%%%%%%%%%   pzmodel(gain, delay)   %%%%%%%%%%
            
            if callerIsMethod
              obj.gain =  varargin{1};
              obj.delay = varargin{2};
            else
              pl = plist('gain', varargin{1}, 'delay', varargin{2});
              obj = fromPolesAndZeros(obj, pl, callerIsMethod);
            end
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  f = pzmodel(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pzmodel('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isa(varargin{1}, 'pzmodel') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = pzmodel(pzmodel-object, <empty plist>)   %%%%%%%%%%
            obj = pzmodel(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = pzmodel(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   pzmodel(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = pzmodel(varargin{2});
              else
                obj = pzmodel(varargin{1});
              end
            else
              obj = pzmodel(varargin{2});
            end
            
          else
            error('### Unknown 2 argument constructor.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Three inputs %%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   pzmodel('to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            %%%%%%%%%%   pzm = pzmodel(gain, poles, zeros)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from poles and zeros');
            if callerIsMethod
              pl.gain = varargin{1};
              pl.poles = varargin{2};
              pl.zeros = varargin{3};
              pl.delay = [];
            else
              pl  = plist('gain', varargin{1}, 'poles', varargin{2}, 'zeros', varargin{3});
            end
            obj = fromPolesAndZeros(obj, pl, callerIsMethod);
          end
          
        case 4
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% Four inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isnumeric(varargin{1})  && ischar(varargin{4})
            %%%%%%%%%%   pzm = pzmodel(gain, poles, zeros, name)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from poles and zeros');
            if callerIsMethod
              pl.gain  = varargin{1};
              pl.poles = varargin{2};
              pl.zeros = varargin{3};
              pl.delay = [];
            else
              pl  = plist('gain', varargin{1}, 'poles', varargin{2}, 'zeros', varargin{3}, 'name', varargin{4});
            end
            obj = fromPolesAndZeros(obj, pl, callerIsMethod);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pzmodel('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(varargin{1})  && isnumeric(varargin{4})
            %%%%%%%%%%   pzm = pzmodel(gain, poles, zeros, delay)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from poles and zeros and delay');
            if callerIsMethod
              pl.gain  = varargin{1};
              pl.poles = varargin{2};
              pl.zeros = varargin{3};
              pl.delay = varargin{4};
            else
              pl  = plist('gain', varargin{1}, 'poles', varargin{2}, 'zeros', varargin{3}, 'delay', varargin{4});
            end
            obj = fromPolesAndZeros(obj, pl, callerIsMethod);
            
          else
            error('### Unknown 4 argument constructor.');
          end
          
        case 5
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%% five inputs %%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isnumeric(varargin{1}) && isa(varargin{4}, 'unit') && isa(varargin{5}, 'unit')
            %%%%%%%%%%   pzm = pzmodel(gain, poles, zeros, in<unit-object>, out<unit-object>)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from poles, zeros and i/o-units');
            if callerIsMethod
              pl.gain   = varargin{1};
              pl.poles  = varargin{2};
              pl.zeros  = varargin{3};
            else
              pl  = plist('gain', varargin{1}, 'poles', varargin{2}, 'zeros', varargin{3}, 'iunits', varargin{4}, 'ounits', varargin{5});
            end
            obj = fromPolesAndZeros(obj, pl, callerIsMethod);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   pzmodel('long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(varargin{1})  && isnumeric(varargin{4}) && ischar(varargin{5})
            %%%%%%%%%%   pzm = pzmodel(gain, poles, zeros, delay, name)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from poles, zeros delay and name');
            if callerIsMethod
              pl.gain   = varargin{1};
              pl.poles  = varargin{2};
              pl.zeros  = varargin{3};
              pl.delay  = varargin{4};
            else
              pl  = plist('gain', varargin{1}, 'poles', varargin{2}, 'zeros', varargin{3}, 'delay', varargin{4}, 'name', varargin{5});
            end
            obj = fromPolesAndZeros(obj, pl, callerIsMethod);
            
          else
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   pzmodel('very', 'long', 'path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [pzs, ~, rest] = utils.helper.collect_objects(args, 'pzmodel');
            
            %%% Do we have a list of PZMODELs as input
            if ~isempty(pzs) && isempty(rest)
              obj = pzmodel(pzs);
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
    
    f = getlowerFreq(varargin)
    f = getupperFreq(varargin)
    
    varargout = tomiir(varargin)
    varargout = tomfir(varargin)
    varargout = fngen(varargin)
    
    varargout = setGain(varargin)
    varargout = setDelay(varargin)
    varargout = setPoles(varargin)
    varargout = setZeros(varargin)
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
        {'From LISO File'},  ...
        {'From Rational'},   ...
        {'From Parfrac'},   ...
        {'From Poles/Zeros'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if isempty(pl) || ~strcmp(lastset, set)
        pl = pzmodel.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = pzmodel.newarray([varargin{:}]);
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
    varargout = fromLISO(varargin)
    varargout = fromStruct(varargin)
    varargout = pzm2ab(varargin)
    varargout = respCore(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(pzmodel.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = pzmodel.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from poles/zeros'
          
          % Gain
          p = param({'gain','Model gain.'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Poles
          p = param({'poles',['Vector/Cell-array of poles. Use either pz objects or the format<br>'...
            'like <tt>{[f1, q1], f2, f3, [f4, q4]}<tt>']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Zeros
          p = param({'zeros',['Vector/Cell-array of zeros. Use either pz objects or the format<br>'...
            'like <tt>{[f1, q1], f2, f3, [f4, q4]}<tt>']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Delay
          p = param({'delay','The delay of the model in seconds.'}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          
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
          
        case 'from parfrac'
          
          % rational
          p = param({'parfrac','Partial fractions transfer-function model object to design from.'}, {1, {parfrac}, paramValue.OPTIONAL});
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the model.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from liso file'
          % Filename
          p = param({'filename','LISO filename.'}, paramValue.EMPTY_STRING);
          out.append(p);
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    varargout = fromPolesAndZeros(varargin)
    varargout = fromRational(varargin)
    varargout = fromParfrac(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    [ao,bo] = abcascade(a1,b1,a2,b2)
  end
  
end % End classdef

