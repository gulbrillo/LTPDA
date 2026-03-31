% RESP gives the timewise impulse response of a statespace model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESP gives the timewise impulse response of a statespace
%              model.
%
% CALL: mat_out = resp(sys, plist_inputs)
%
% INPUTS:
%         - sys, (array of) ssm object
%
% plist with parameters 'inputs', 'states' and 'outputs' to indicate which
% inputs, states and outputs variables are taken in account. This requires
% proper variable naming. If a variable called appears more that once it
% will be used once only.
%
% OUTPUTS:
%         - mat_out contains the timewise response (one for each input)
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'resp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = resp(varargin)
  %% starting initial checks
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % checking number of inputs work data
  in_names = cell(size(varargin));
  for oo = 1:nargin,in_names{oo} = inputname(oo);end
  
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, ssm_invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist', in_names);
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  
  %% begin function body
  if numel(sys)>1
    error('ssm/resp only works with a single statespace model.')
  end
  
  if ~sys.isnumerical
    error('The input system should be numeric.')
  end
  
  %% modifying input ssm
  if sys.timestep == 0
    sys = copy(sys, true);
    sys.modifyTimeStep('newtimestep', 0.1);
    warning('Warning : time-continuous ssm was discretized with a time-step of 0.1s per default') %#ok<WNTAG>
  end
  
  %% getting duration of the response
  tmax = find(pl, 'tmax');
  if sys.isStable && (tmax == -1)
    pl_s = settlingTime(sys, pl);
    timeMax = min(find(pl_s, 'SETTLING_TIME'), 1e5);
    timeMax = nextPow2( 12* timeMax);
  else
    timeMax = nextPow2( tmax./sys.timestep);
  end
  
  %% deriving and initializing matrices
  if find(pl, 'reorganize')
    sys = copy(sys, true);
    sys = reorganize(sys, pl, plist('set', 'for resp'));
  end
  
  A = sys.amats{1,1};
  B = sys.bmats{1,1};
  C = sys.cmats{2,1};
  Cstates = sys.cmats{1,1};
  D = sys.dmats{2,1};
  Ts = sys.timestep;
  
  Ninputs = size(B,2);
  Noutputs = size(C,1);
  Nss = size(A,1);
  NssOut = size(Cstates,1);
  
  %% collecting data before saving in loop
  aos = ao.initObjectWithSize(Noutputs+NssOut, Ninputs);
  inhist = sys.hist;
  
  inputType = find(pl, 'response');
  
  for ii=1:Ninputs
    
    %% depending on user option, compute response for one input only
    if strcmpi( inputType, 'IMPULSE')
      stateVect = zeros(Nss,2^timeMax);
      stateVect(:,1) = B(:,ii)/sys.timestep;
      a = A;
      for k=1:timeMax
        p = k-1;
        stateVect(:,1:2^k) = [stateVect(:,1:2^p) a*stateVect(:,1:2^p)];
        a = a*a;
      end
      outputVect = C*stateVect;
      outputVect(:,1) = outputVect(:,1) + D(:,ii);
      stateVect = Cstates*stateVect;
      respName = 'Impulse';
      
    elseif strcmpi( inputType, 'STEP')
      stateVect = zeros(Nss,2^timeMax);
      stateVect(:,1) = B(:,ii);
      stateBasis = B(:,ii);
      outputVect =  zeros(Noutputs,2^timeMax);
      outputVect(:,1) = D(:,ii);
      a_powP = A;
      for k=1:timeMax
        p = k-1;
        outputVect(:,1:2^k) = [ outputVect(:,1:2^p) outputVect(:,1:2^p) ];
        lastStates = stateVect(:,1:2^p);
        stateVect(:,(2^p+1):2^k) = a_powP*lastStates + diag(stateBasis)*ones(Nss, 2^p) ;
        % update iterative matrices
        stateBasis = a_powP*stateBasis + stateBasis;
        a_powP = a_powP*a_powP;
      end
      outputVect = C*stateVect + outputVect;
      outputVect = [ zeros(Noutputs,1) outputVect]; %#ok<AGROW>
      stateVect = Cstates*stateVect;
      respName = 'Step';
      
    else
      error(['Option ''response'' does not accept the value' inputType]);
    end
    
    %% storing response in aos for one input only
    
    for oo=1:NssOut;
      aos(oo,ii).setData(tsdata(stateVect(oo,:), 1/Ts));
      aos(oo,ii).setName([sys.inputs(1).ports(ii).name '->' sys.outputs(1).ports(oo).name]);
      aos(oo,ii).setXunits(unit.seconds);
      aos(oo,ii).setYunits(sys.outputs(1).ports(oo).units);
      aos(oo,ii).setDescription([respName ' response from input ' , sys.inputs(1).ports(ii).name , 'to output ',  sys.outputs(1).ports(oo).name]);
      aos(oo,ii).setT0(sys.timestep);
    end
    for oo=1:Noutputs;
      aos(NssOut+oo,ii).setData(tsdata( outputVect(oo,:), 1/Ts));
      aos(NssOut+oo,ii).setName([sys.inputs(1).ports(ii).name '->' sys.outputs(2).ports(oo).name]);
      aos(NssOut+oo,ii).setXunits(unit.seconds);
      aos(NssOut+oo,ii).setYunits(sys.outputs(2).ports(oo).units);
      aos(NssOut+oo,ii).setDescription([respName ' response from input ' , sys.inputs(1).ports(ii).name , 'to output ',  sys.outputs(2).ports(oo).name]);
      aos(NssOut+oo,ii).setT0(sys.timestep);
    end
  end
  
  %% construct output matrix object
  out = matrix(aos);
  if callerIsMethod
    % do nothing
  else
    myinfo = getInfo('None');
    out.addHistory(myinfo, pl , ssm_invars(1), inhist );
  end
  
  %% Set output depending on nargout
  if nargout == 1;
    varargout = {out};
  elseif nargout == 2;
    varargout = {out plist_out};
  elseif nargout == 0;
    iplot(aos);
  else
    error('Wrong number of outputs')
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function oo = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  oo = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function pl = getDefaultPlist()
  pl = ssm.getInfo('reorganize', 'for resp').plists;
  pl.remove('set');
  
  p = param({'response', 'Specify the type of response wanted'},{1, {'impulse', 'step'}, paramValue.SINGLE} );
  pl.append(p);
  
  p = param({'tmax', 'Specify the duration of response wanted [s] (automatically set if not specified by user, and system is stable)'},-1 );
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  
end
