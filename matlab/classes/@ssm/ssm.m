% SSM statespace model class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM statespace model class constructor.
%
% CONSTRUCTORS:
%
%       s = ssm()            - creates an empty statespace model
%       s = ssm('a1.xml')    - creates a new statespace model by loading the
%                              object from disk.
%       s = ssm('a1.mat')    - creates a new statespace model by loading the
%                              object from disk.
%       a = ssm(plist)       - creates a statespace model from the description
%                              given in the parameter list
%       a = ssm(struct)      - creates a statespace model from the
%                              structure returned by struct(ssm).
%
%
% EXAMPLES:
%
% 1) Construct an SSM object by description:
%
%                 name = 'sys';
%                 statenames = {'ss1' 'ss2' 'ss3'};
%                 inputnames = {'input1' 'input2' 'input3'};
%                 outputnames = {'output1' 'output2' 'output3'};
%                 timestep = 0;
%                 params = plist({'omega', 'system frequency'}, 2);
%                 amats = cell(3, 3);
%                 bmats = cell(3, 3);
%                 cmats = cell(3, 3);
%                 dmats = cell(3, 3);
%                 amats{1, 1} = -(sym('omega'));
%                 amats{2, 2} = -2;
%                 amats{3, 3} = -3*eye(2);
%                 amats{3, 1} = [-1;-3];
%                 bmats{1, 1} = 1;
%                 bmats{2, 2} = 2;
%                 bmats{3, 3} = 3*eye(2);
%                 cmats{1, 1} = 1;
%                 cmats{2, 2} = 1;
%                 cmats{3, 3} = eye(2);
%                 dmats{1, 3} = [6 6];
%                 dmats{2, 1} = 6;
%                 dmats{3, 2} = [6;6];
%                 sys = ssm(plist( ...
%                   'amats', amats, 'bmats', bmats, 'cmats', cmats, 'dmats', dmats, ...
%                   'timestep', timestep, 'name', name, 'params', params, ...
%                   'statenames', statenames, 'inputnames', inputnames, 'outputnames', outputnames ));
%
%
%     A shortcut (incomplete) syntax is :
%                sys = ssm( amats, bmats, cmats, dmats, timestep, name, params, ...
%                           statenames, inputnames, outputnames )
%     Also :
%                sys = ssm(miirObject);
%                sys = ssm(rationalObject);
%                sys = ssm(parfracObject);
%
%     More complete call
%                % here computation of the system's matrices, declaration
%                % of parameters, some symbolic may be stored in the user
%                % plist
%                sys = struct
%                SMD_W = 0.2;  SMD_C = 0.5; SMD_S1 = 0; SMD_S2 = 0; SMD_B = 1; SMD_D1 = 0;
%                sys.params = plist;
%
%
%                sys.amats    = {[0 1 ; -SMD_W*SMD_W -2*SMD_C*SMD_W]};
%                sys.cmats    = {[1+SMD_S1 SMD_S2]};
%                sys.bmats    = {[0;SMD_B] [0 0; 1 0]};
%                sys.dmats    = {SMD_D1 [0 1]};
%
%                sys.timestep = 0;
%
%                sys.name = 'SRPINGMASSDAMPER';
%                sys.description = 'standard spring-mass-damper test system';
%
%                inputnames    = {'CMD' 'DIST_SMD'};
%                inputdescription = {'force noise' 'observation noise'};
%                inputvarnames = {{'F'} {'F' 'S'}};
%                inputvarunits = {unit('kg m s^-2') [unit('kg m s^-2') unit('m')]};
%                inputvardescription = [];
%
%                ssnames    = {'SMD'};
%                ssdescription = {'TM position and speed'};
%                ssvarnames = {{'x' 'xdot'}};
%                ssvarunits={[unit('m') unit('m s^-1')]};
%                ssvardescription = [];
%
%                outputnames    = {'SMD'};
%                outputdescription = {'observed position'};
%                outputvarnames ={{'OBS'}};
%                outputvarunits={unit('m')};
%                outputvardescription = [];
%
%                %% Build ssmblocks
%                sys.inputs = ssmblock.makeBlocksWithData(inputnames, inputdescription, inputvarnames, inputvarunits, inputvardescription);
%                sys.outputs = ssmblock.makeBlocksWithData(outputnames, outputdescription, outputvarnames, outputvarunits, outputvardescription);
%                sys.states =  ssmblock.makeBlocksWithData(ssnames, ssdescription, ssvarnames, ssvarunits, ssvardescription);
%                %% plist constructors
%                sys = ssm(plist( ...
%                  'amats',sys.amats, 'bmats', sys.bmats, 'cmats', sys.cmats, 'dmats', sys.dmats, ...
%                  'timestep', 0, 'name', sys.name, 'inputs', sys.inputs, ...
%                  'states', sys.states, 'outputs', sys.outputs));
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ssm < ltpda_uoh
  
  %% -------- Private read-only Properties --------
  properties (SetAccess = protected)
    amats          = {}; % A matrix representing a difference/differential term in the state equation, block stored in a cell array
    bmats          = {}; % B matrix representing an input coefficient matrix in the state equation, block stored in a cell array
    cmats          = {}; % C matrix representing the state projection in the observation equation, block stored in a cell array
    dmats          = {}; % D matrix representing the direct feed through term in the observation equation, block stored in a cell array
    timestep       = 0; % Timestep of the difference equation. Zero means the representation is time continuous and A defines a differential equation.
    inputs         = ssmblock.initObjectWithSize(1,0); % ssmblock for input blocks
    states         = ssmblock.initObjectWithSize(1,0); % ssmblock  describing state blocks
    outputs        = ssmblock.initObjectWithSize(1,0); % ssmblock  describing the output blocks
    numparams      = plist.initObjectWithSize(1,1); % nested plist describing the numeric (substituted) parameters
    params         = plist.initObjectWithSize(1,1); % nested plist describing the symbolic parameters
  end % End read only properties
  
  %% -------- Dependant Properties ---------
  properties (Dependent)
    Ninputs  % Number of input-blocks, it is a double
    inputsizes   % Size corresponding to each input-block in the B/D matrices. It is a double vector
    Noutputs % Number of output-blocks, it is a double
    outputsizes   % Size corresponding to each output-block in the C/D matrices. It is a double vector
    Nstates  % Number of state-blocks, it is a double
    statesizes   % Size corresponding to each state-block in the A/B/C matrices. It is a double vector
    Nnumparams % number of parameters, a double;
    Nparams  % number of parameters, a double;
    isnumerical   % This binary tells whether the system has numerical content only, or symbolic as well
  end
  
  %% -------- Dependant Properties ---------
  properties (Dependent, Hidden)
    Nss  % Number of state-blocks, it is a double
    sssizes % Size corresponding to each state-block in the A/B/C matrices. It is a double vector
    inputnames % Cell array with input blocks names
    inputvarnames % Embedded cell array with input ports names
    ssnames % Cell array with states blocks names
    ssvarnames % Embedded cell array with states ports names
    statenames % Cell array with states blocks names
    statevarnames % Embedded cell array with states ports names
    outputnames % Cell array with output blocks names
    outputvarnames % Embedded cell array with output ports names
    paramnames % Cell array with input parameter names
    paramvalues % Double array with input parameter values - may not work with new paramvalue class
    numparamnames % Cell array with input parameter names
    numparamvalues % Double array with input parameter values - may not work with new paramvalue class
  end  %-------- Protected Properties ---------
  
  %% -------- Dependant Properties Methods ------
  methods
    
    function value = get.Ninputs(obj)
      value = size(obj.bmats,2);
    end
    
    function value = get.inputsizes(obj)
      Ninputs = obj.Ninputs;
      Nstates = obj.Nstates;
      Noutputs = obj.Noutputs;
      if Nstates==0 && Ninputs~=0 && Noutputs==0
        error('This ssm has matrix sizes that make it impossible to determine the property inputsizes (0 states, 1+ inputs and 0 output)')
      end
      value = zeros(1, Ninputs);
      for k=1:Ninputs
        % b matrix vertically
        for p=1:Nstates
          value(k) = size(obj.bmats{p,k} ,2);
          if value(k)>0
            break
          end
        end
        % d matrix vertically
        if value(k)==0
          for p=1:Noutputs
            value(k) = size(obj.dmats{p,k} ,2);
            if value(k)>0
              break
            end
          end
        end
      end
    end
    
    function value = get.Noutputs(obj)
      value = size(obj.cmats,1);
    end
    
    function value = get.outputsizes(obj)
      Ninputs = obj.Ninputs;
      Nstates = obj.Nstates;
      Noutputs = obj.Noutputs;
      if Nstates==0 && Ninputs==0 && Noutputs~=0
        error('This ssm has matrix sizes that make it impossible to determine the property outputsizes (0 states, 0 input and 1+ outputs)')
      end
      value = zeros(1, Noutputs);
      for k=1:Noutputs
        % c matrix horizontally
        for p=1:Nstates
          value(k) = size(obj.cmats{k,p} ,1);
          if value(k)>0
            break
          end
        end
        % d matrix horizontally
        if value(k)==0
          for p=1:Ninputs
            value(k) = size(obj.dmats{k,p} ,1);
            if value(k)>0
              break
            end
          end
        end
      end
    end
    
    function value = get.Nstates(obj)
      value = size(obj.amats,1);
    end
    
    function value = get.statesizes(obj)
      Ninputs = obj.Ninputs;
      Nstates = obj.Nstates;
      Noutputs = obj.Noutputs;
      value = zeros(1, Nstates);
      for k=1:Nstates
        % b matrix horizontally
        for p=1:Ninputs
          value(k) = size(obj.bmats{k,p}, 1);
          if value(k)>0
            break
          end
        end
        % a matrix horizontally
        if value(k)==0
          for p=1:Nstates
            value(k) = size(obj.amats{k,p}, 1);
            if value(k)>0
              break
            end
          end
        end
        % a matrix vertically
        if value(k)==0
          for p=1:Nstates
            value(k) = size(obj.amats{p,k}, 2);
            if value(k)>0
              break
            end
          end
        end
        % c matrix vertically
        if value(k)==0
          for p=1:Noutputs
            value(k) = size(obj.cmats{p,k}, 2);
            if value(k)>0
              break
            end
          end
        end
      end
    end
    
    function value = get.Nss(obj)
      value = obj.Nstates;
    end
    
    function value = get.sssizes(obj)
      value = obj.statesizes;
    end
    
    function value = get.Nparams(obj)
      value = obj.params.nparams;
    end
    
    function value = get.Nnumparams(obj)
      value = obj.numparams.nparams;
    end
    
    
    function value = get.isnumerical(obj)
      value = true;
      for i=1:numel(obj.amats)
        if ~isa(obj.amats{i}, 'double'),
          value = false; return;
        end
      end
      for i=1:numel(obj.bmats)
        if ~isa(obj.bmats{i}, 'double')
          value = false; return;
        end
      end
      for i=1:numel(obj.cmats)
        if ~isa(obj.cmats{i}, 'double')
          value = false; return;
        end
      end
      for i=1:numel(obj.dmats)
        if ~isa(obj.dmats{i}, 'double')
          value = false; return;
        end
      end
    end
    
    function names = get.inputnames(obj)
      names = obj.inputs.blockNames;
    end
    
    function names = get.inputvarnames(obj)
      names = obj.inputs.portNames;
    end
    
    function names = get.ssnames(obj)
      names = obj.statenames;
    end
    
    function names = get.ssvarnames(obj)
      names = obj.statevarnames;
    end
    
    function names = get.statenames(obj)
      names = obj.states.blockNames;
    end
    
    function names = get.statevarnames(obj)
      names = obj.states.portNames;
    end
    
    function names = get.outputnames(obj)
      names = obj.outputs.blockNames;
    end
    
    function names = get.outputvarnames(obj)
      names = obj.outputs.portNames;
    end
    
    function names = get.paramnames(obj)
      Nparams = obj.params.nparams;
      names = cell(1, Nparams);
      for i=1:Nparams
        names{i} = obj.params.params(i).key;
      end
    end
    
    function values = get.paramvalues(obj)
      Nparams = obj.params.nparams;
      values = zeros(1, Nparams);
      for i=1:Nparams
        values(i) = obj.params.params(i).getVal;
      end
    end
    
    function names = get.numparamnames(obj)
      Nnumparams = obj.numparams.nparams;
      names = cell(1, Nnumparams);
      for i=1:Nnumparams
        names{i} = obj.numparams.params(i).key;
      end
    end
    
    function values = get.numparamvalues(obj)
      Nnumparams = obj.numparams.nparams;
      values = zeros(1, Nnumparams);
      for i=1:Nnumparams
        values(i) = obj.numparams.params(i).getVal;
      end
    end
    
    function set.inputnames(obj, inputnames)
      if ~obj.Ninputs == numel(inputnames)
        error('### error : Input size is wrong')
      end
      if obj.Ninputs == numel(obj.inputs)
        obj.inputs.setBlockNames(inputnames);
      else
        obj.inputs = ssmblock.makeBlocksWithSize(obj.inputsizes, inputnames);
      end
      % history to be added ?
    end
    
    function set.statenames(obj, statenames)
      if ~obj.Nstates == numel(statenames)
        error('### error : Input size is wrong')
      end
      if (obj.Nstates == numel(obj.states))
        obj.states.setBlockNames(statenames);
      else
        obj.states = ssmblock.makeBlocksWithSize(obj.statesizes, statenames);
      end
      % history to be added ?
    end
    
    function set.outputnames(obj, outputnames)
      if ~obj.Noutputs == numel(outputnames)
        error('### error : Input size is wrong')
      end
      if obj.Noutputs == numel(obj.outputs)
        obj.outputs.setBlockNames(outputnames);
      else
        obj.outputs = ssmblock.makeBlocksWithSize(obj.outputsizes, outputnames);
      end
      % history to be added ?
    end
    
    function set.ssnames(obj, ssnames)
      obj.statenames = ssnames;
    end
    
  end
  
  %% -------- constructor ------
  methods(Access = public)
    
    function s = ssm(varargin)
      import utils.const.*
      
      utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
      
      % Initialize the properties to make sure that the pointer points to a
      % new object.
      s.numparams = plist();
      s.numparams.setName('numparams');
      s.params    = plist();
      s.params.setName('params');
      
      % empty constructor
      if nargin == 0
        %%%%%%%%%%  s = ssm()   %%%%%%%%%%
        s.addHistory(ssm.getInfo('ssm', 'None'), plist(), [], []);
        return
      end
      
      % copy constructor
      % Collect all ssm objects to check for copy constructor
      sss = utils.helper.collect_objects(varargin(:), 'ssm');
      if ~isempty(sss)
        %%%%%%%%%%  s = ssm(<ssm objects>)   %%%%%%%%%%
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        s = copy(sss, 1);
        for kk=1:numel(s)
          s(kk).addHistory(ssm.getInfo('ssm', 'None'), [], [], s(kk).hist);
        end
        return
      end
      
      % one input constructor
      if (nargin == 1)
        
        % constructor with one object
        vin = varargin{1};
        if any( strcmp(class(vin), {'pzmodel', 'rational', 'parfrac', 'struct', 'miir', 'ss' } ))
          %%%%%%%%%%  s = ssm(<model object>)   %%%%%%%%%%
          s = ssm(vin, plist);
          return
        end
        
        
        % constructor from a plist with no object inside
        %
        % the object may only be validated in the constructor
        % the history may only be added in the constructor
        if isa(vin, 'plist')
          %%%%%%%%%%  s = ssm(<empty plist>)   %%%%%%%%%%
          if vin.nparams == 0              % empty constructor with a plist
            utils.helper.msg(msg.OPROC1, 'empty constructor %s', varargin{1}.name);
            s.addHistory(ssm.getInfo('ssm', 'None'), vin, [], []);
            return
            %%%%%%%%%%  s = ssm(<plist with no model object inside>)   %%%%%%%%%%
          elseif isparam_core(vin,'amats')      % construct from a plist description
            utils.helper.msg(msg.OPROC1, 'constructor from a description %s', varargin{1}.name);
            s = ssm.ssmFromDescription(vin);
            s.addHistory(ssm.getInfo('ssm', 'None'), vin, [], []);
            return
          elseif isparam_core(vin,'Built-in')   % Construct from built-in models
            utils.helper.msg(msg.OPROC1, 'constructing from Built-in model %s', varargin{1}.name);
            vin.pset('Built-in', vin.find('Built-in'));
            if isparam_core(vin, 'withparams')
              error('The WITHPARAMS key has been changed to SYMBOLIC PARAMS. Please check your plist');
            end
            s = fromModel(s,vin);
            s.validate; % validate when a new object is built
            return
          elseif isparam_core(vin,'Hostname')   % Retrieve from repository
            utils.helper.msg(msg.OPROC1, 'constructing from repository %s', varargin{1}.name);
            s = s.fromRepository(vin);
            return
          elseif isparam_core(vin,'Filename')   % filename constructor
            utils.helper.msg(msg.OPROC1, 'constructing from filename %s', varargin{1}.name);
            s = s.fromFile(vin);
            return
            
            % constructor from a plist with an object inside
            %
            % the object is retrieved out of the plist and removed from the
            % plist to make it lighter. The input is parsed to the ssm
            % constructor with two inputs. History and validation are done in
            % there.
            % There is no message since it is displayed in the call to ssm
            % later on
            
            %%%%%%%%%%  s = ssm(<plist with model-object inside>)   %%%%%%%%%%
          elseif isparam_core(vin,'pzmodel')
            obj = find(vin, 'pzmodel');
            vin.remove('pzmodel')
          elseif isparam_core(vin,'rational')
            obj = find(vin, 'rational');
            vin.remove('rational')
          elseif isparam_core(vin,'parfrac')
            obj = find(vin, 'parfrac');
            vin.remove('parfrac')
          elseif isparam_core(vin,'struct')
            obj = find(vin, 'struct');
            vin.remove('struct')
          elseif isparam_core(vin,'miir')
            obj = find(vin, 'miir');
            vin.remove('miir')
          elseif isparam_core(vin,'ss')
            obj = find(vin, 'ss');
            vin.remove('ss')
          else
            display('###   Unknown ssm constructor could not find a valid parameter key  ###')
            display('###   these are : ''Filename'' ''Built-in'' ''pzmodel'' ''miir'' ''amats''    ###')
            display('###               ''Hostname'' ''rational'' ''struct'' ''ss''               ###')
            error('');
          end
          s = ssm(obj, vin);
          return
        end
        
        
        % constructor with an input string
        if isa(vin, 'char')
          %%%%%%%%%%  s = ssm(filename)   %%%%%%%%%%
          s = ssm(plist('Filename', vin));
          return
        end
        
        % in the worst case, try with the same input and a plist !? Not
        % Yet (TBD)
        display('###   Unknown ssm one-object constructor,  allowed object classes are:  ###')
        display('###   ''plist'' ''pzmodel'' ''rational'' ''parfrac'' ''struct'' ''miir'' ''ss''        ###')
        error('');
      end
      
      % two inputs constructors
      switch nargin
        case 2
          obj = varargin{1};
          pl = varargin{2};
          
          if isa(pl, 'plist')
            if isstruct(obj)
              %%%%%%%%%%  s = ssm(struct, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'contructing from a structure');
              s = fromStruct(s, obj);
              doValidate = true;
            elseif isa(obj, 'pzmodel')
              %%%%%%%%%%  s = ssm(pzmodel, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', varargin{1}.name);
              s = ssm.ssmFromPzmodel( obj, pl);
              doValidate = true;
            elseif isa(obj, 'miir')
              %%%%%%%%%%  s = ssm(miir, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from miir %s', varargin{1}.name);
              s = ssm.ssmFromMiir(obj, pl);
              doValidate = true;
            elseif isa(obj, 'ss')
              %%%%%%%%%%  s = ssm(ss, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from ss %s', varargin{1}.name);
              s = ssm.ssmFromss(obj, pl);
              doValidate = true;
            elseif isa(obj,'char') && pl.isparam_core('filename')
              %%%%%%%%%%  s = ssm(filename, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from filename %s', varargin{1}.name);
              filename = varargin{1};
              s = s.fromFile(filename);
              doValidate = false;
            elseif isa(obj, 'rational')
              %%%%%%%%%%  s = ssm(rational, plist)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'constructing from rational %s', varargin{1}.name);
              s = ssm.ssmFromRational(obj,pl);
              doValidate = true;
            elseif isa(obj, 'parfrac')
              %%%%%%%%%%  s = ssm(parFrac)   %%%%%%%%%%
              s = ssm.ssmFromParfrac(obj, pl);
              doValidate = true;
            elseif isa(obj, 'ssm') && pl.nparams == 0
              s = ssm(obj);
            elseif isa(obj, 'plist')
              % if for some reason we have two input plists, combine them.
              %%%%%%%%%%  s = ssm(plist, plist)   %%%%%%%%%%
              s = ssm(obj.combine(plist));
              return;
            else
              error(['### Error: ssm constructor cannot accept input of type : ',class(obj)]);
            end
            
            % Now validate this object
            if doValidate
              s.validate();
            end
            
          elseif iscellstr(varargin)
            %%%%%%%%%%  s = ssm('dir', 'objs.xml')   %%%%%%%%%%
            s = fromFile(s, fullfile(varargin{:}));
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  s = ssm(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            s = s.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif ischar(varargin{1})
            %%%%%%%%%  s = ssm('str1', param1)   %%%%%%%%%%
            s = ssm(plist(varargin{1},varargin{2}));
            s.validate();
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = ssm(DOM node, history-objects)   %%%%%%%%%%
            s = fromDom(s, varargin{1}, varargin{2});
            
          else
            error('### Unknown two parameter constructor.');
          end
          
          % contructor with more than 2 inputs, which cannot be the copy
          % constructor (done at the beggining)
        otherwise
          if iscellstr(varargin)
            %%%%%%%%%%  s = ssm('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            s = fromFile(s, fullfile(varargin{:}));
            
          elseif ischar(varargin{1})
            %%%%%%%%%%  s = ssm('str1', param1, 'str2', param2 ...)   %%%%%%%%%%
            try
              vin = plist(varargin{:});
            catch
              error('### Unknown constructor - ssm tried to make a plist with the constructor inputs, but it did not work.');
            end
            s = ssm(vin);
            
          else % Try shortcut call with a description
            try
              %%%%%%%%%%  s = ssm(amats, bmats, cmats,...)   %%%%%%%%%%
              utils.helper.msg(msg.OPROC1, 'attempting building a description');
              keynames = {'amats', 'bmats', 'cmats', 'dmats', 'timestep', 'name', 'params'...
                'statenames', 'inputnames', 'outputnames' };
              pli = plist;
              for i=1:numel(keynames)
                if i<=nargin
                  pli.append( plist(keynames{i},varargin{i}) );
                end
              end
              s = ssm(pli);
            catch ME
              error(ME.identifier, '### Unknown constructor with more than 2 arguments.');
            end
          end
      end
    end
    
  end  % -------- constructor ------
  
  %% -------- Declaration of hidden methods --------
  methods (Hidden = true)
    
    % loglikelihood_core ssm
    varargout = loglikelihood_core(varargin);
    
    varargout = setA(varargin);
    varargout = setB(varargin);
    varargout = setC(varargin);
    varargout = setD(varargin);
    
    function clearNumParams(sys)
      sys.numparams = plist;
    end
    
    function clearAllUnits(sys)
      sys.inputs.clearAllUnits;
      sys.states.clearAllUnits;
      sys.outputs.clearAllUnits;
    end
    varargout = fisher(varargin)
    varargout = diffStepFish(varargin)
    
    % completion and error check
    varargout = validate(varargin)
    % copying one ssm
    varargout = copy(varargin)
    % process system simplification
    varargout = doSimplify(varargin)
    % process parameter setting
    varargout = doSetParameters(varargin)
    % process parameter substitution
    varargout = doSubsParameters(varargin)
    % re-arrangement of ssm
    sys = reshuffle(sys, inputs1, inputs2, inputs3,  states, outputs, outputStates)
  end
  
  %% -------- Declaration of Public Static methods --------
  methods (Static=true, Access=public)
    
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
      out = [SETS@ltpda_uoh,  ...
        {'From Description'}, ...
        {'From Pzmodel'},     ...
        {'From Miir'},        ...
        {'From Rational'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = ssm.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ssm.newarray([varargin{:}]);
    end
    
  end % End public static methods
  
  %% -------- Declaration of public methods --------
  methods
    
    varargout = getParams(varargin)
    varargout = setParams(varargin)
    
    varargout = setBlockProperties(varargin)
    varargout = setPortProperties(varargin)
    % loglikelihood ssm
    varargout = loglikelihood(varargin)
    % change timestep
    varargout = modifyTimeStep(varargin)
    % add, change and subsitute parameters
    varargout = addParameters(varargin)
    varargout = subsParameters(varargin)
    varargout = setParameters(varargin)
    varargout = keepParameters(varargin)
    varargout = getParameters(varargin)
    % copy one input block
    varargout = duplicateInput(varargin)
    % assemble systems
    varargout = assemble(varargin)
    % append systems
    varargout = append(varargin)
    % transform into a iir
    varargout = ssm2miir(varargin)
    % transform into a pzmodel
    varargout = ssm2pzmodel(varargin)
    % transform into ABCD doubles/symb
    varargout = double(varargin)
    % returns aos with impulse or step response
    varargout = resp(varargin)
    % returns aos with impulse or step response (uses control toolbox)
    varargout = respcst(varargin)
    % transform into a matlab ss object
    varargout = ssm2ss(varargin)
    % simulation
    varargout = simulate(varargin)
    % kalman filter
    varargout = kalman(varargin)
    % model simplification (variables)
    varargout = simplify(varargin)
    % give minimal realization
    varargout = MinReal(varargin)
    % give minimal systematic realization
    varargout = sMinReal(varargin)
    % tells if ssm is stable
    varargout = isStable(varargin)
    % returns a value for steady state
    varargout = steadyState(varargin)
    % returns a value for the system's settling time
    varargout = settlingTime(varargin)
    % returns a system with output diferrenciated in regards with parameters
    varargout = parameterDiff(varargin)
    % returns the expected output spectrum of the ssm
    varargout = psd(varargin)
    varargout = cpsd(varargin) % takes coupled inputs but does not return individual contributions
    % reorganize ssm for simulation, PSD, BODE...
    varargout = reorganize(varargin)
    % display ports/plists
    varargout = displayProperties(varargin)
  end
  
  methods (Access = private)
  end
  
  %% -------- Declaration of Hidden Static methods --------
  methods (Static=true, Hidden=true)
    % create from miir
    varargout = ssmFromMiir(varargin)
    % create from rational
    varargout = ssmFromRational(varargin)
    % create from parfrac object
    varargout = ssmFromParfrac(varargin)
    % create from ss
    varargout = ssmFromss(varargin)
    % create from plist
    varargout = ssmFromDescription(varargin)
    % create from pzmodel
    varargout = ssmFromPzmodel(varargin)
    % subroutines for block defined matrix calculus
    a_out = blockMatRecut(a, rowsizes, colsizes)
    a_out = blockMatFusion(a, rowsizes, colsizes)
    c = blockMatMult(varargin)
    a = blockMatAdd(varargin)
    a = blockMatIndex(amats, blockIndex1, portIndex1, blockIndex2, portIndex2)
    a = blockMatIndexSym(amats, blockIndex1, portIndex1, blockIndex2, portIndex2)
    varargout = blockMatPrune(varargin)
    a = blockMatFillDiag(a, isizes, jsizes)
    % for built-in models
    varargout = modelHelper_checkParameters(varargin)
    varargout = modelHelper_processInputPlist(varargin)
    [params, numParams] = modelHelper_declareParameters(pl, paramNames, paramValues, paramDescriptions, paramUnits)
    varargout = buildParamPlist(names, value, description, units, pl);
    % indexing in a matrix and I/o block arrays, with selection and
    % permuation matrices
    varargout = getMatrixSelection(blockMat, colSizes, oldColumns, newColumns, rowSizes, oldRows, newRows)
    
    % Chi2 fitting computation
    varargout = computeChiFit(varargin)
    % simulation computation
    [x, y, lastX] = doSimulate(varargin)
    % bode computation
    varargout = doBode(a, b, c, d, w, Ts)
  end
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, protected)                       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = protected)
    function pl = buildplist(set)
      if ~utils.helper.ismember(lower(ssm.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      pl = plist();
      pl = buildplist@ltpda_uoh(pl, set);
      
      switch lower(set) % Select parameter set
        
        case 'from built-in model'
          % Built-in
          % This is inherited
          pl = combine(pl, plist.FROM_BUILT_IN);
          % withParams --> withparams changed to 'symbolic params'
          p = param({'symbolic params',['Give a cell-array of parameter names to keep in the expression.<br>',...
            'By default this is empty and the model will be returned fully numeric.',...
            'You can also specify ''ALL'' to keep all parameters. Some models don''t support this',...
            'option; see the specific help of the models for details.']}, {});
          pl.append(p);
          % SETNAMES --> setnames changed to 'param names'
          p = param({'param names',['Cell-array of parameter names for user defined values.<br>',...
            'This way, parameter values can be modified even if they are never used symbolically.']},{});
          pl.append(p);
          % SETVALUES --> setvalues changed to 'param values'
          p = param({'param values','Array of parameter values for numerical substitutions.'}, paramValue.EMPTY_DOUBLE);
          pl.append(p);
          
        case {'default', 'from description'}
          
          % States
          p = param({'states','State space blocks.'}, ssmblock.initObjectWithSize(1,0));
          pl.append(p);
          % Outputs
          p = param({'outputs','Output blocks.'}, ssmblock.initObjectWithSize(1,0));
          pl.append(p);
          % Inputs
          p = param({'inputs','Input blocks.'}, ssmblock.initObjectWithSize(1,0));
          pl.append(p);
          % Timestep
          p = param({'timestep',['Timestep of the difference equation. Zero means '...
            'the representation is time continuous' ]}, paramValue.DOUBLE_VALUE(0));
          pl.append(p);
          % AMATS
          p = param({'amats',['A matrix representing a difference/differential term in the state equation.',...
            'Specify as a cell-array of matrices.']},   cell(0,0));
          pl.append(p);
          % BMATS
          p = param({'bmats',['B matrix representing an input coefficient matrix in the state equation.',...
            'Specify as a cell-array of matrices.']},   cell(0,0));
          pl.append(p);
          % CMATS
          p = param({'cmats',['C matrix representing the state projection in the observation equation.',...
            'Specify as a cell-array of matrices.']},   cell(0,0));
          pl.append(p);
          % DMATS
          p = param({'dmats',['D matrix representing the direct feed through term in the observation equation.',...
            'Specify as a cell-array of matrices.']},   cell(0,0));
          pl.append(p);
          % Params
          p = param({'params','Parameter data arrays.'}, {1, {plist}, paramValue.OPTIONAL});
          pl.append(p);
          
        case 'from pzmodel'
          p = param({'pzmodel','A pole/zero model object.'}, {1, {pzmodel}, paramValue.OPTIONAL});
          pl.append(p);
          
        case 'from miir'
          p = param({'miir','An IIR filter object (MIIR).'}, {1, {miir}, paramValue.OPTIONAL});
          pl.append(p);
          
        case 'from rational'
          p = param({'rational','A rational (transfer function) model object.'}, {1, {rational}, paramValue.OPTIONAL});
          pl.append(p);
          
      end
      
      % Add the global keys
      pl = ssm.addGlobalKeys(pl);
      
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  
end % End classdef

