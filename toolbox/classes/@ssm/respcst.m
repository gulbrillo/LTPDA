% RESPCST gives the timewise impulse response of a statespace model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESPCST gives the timewise impulse response of a statespace
%              model.
%
% CALL: [aos ] = respcst(sys, plist_inputs)
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
%         - aos the timewise response (one for each input)
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'respcst')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = respcst(varargin)
  %% starting initial checks
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % checking number of inputs work data
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, ssm_invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist', in_names);
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  
  %% begin function body
  if numel(sys)>1
    error('ssm/respcst only works with a single statespace model.')
  end
  
  if ~sys.isnumerical
    error('The input system should be numeric.')
  end
  
  %% modifying input ssm
  if sys.timestep == 0
    sys = copy(sys, true);
    sys.modifyTimeStep(0.1);
    warning('Warning : time-continuous ssm was discretized with a time-step of 0.1s per default') %#ok<WNTAG>
  end
  
  %% getting duration of the response
  tmax = find(pl, 'tmax');
  if sys.isStable && (tmax == -1)
    pl_s = settlingTime(sys, pl);
    timeMax = min(find(pl_s, 'SETTLING_TIME'), 1e5);
    timeMax = 2^nextpow2( 12* timeMax);
  else
    timeMax = 2^nextpow2( tmax./sys.timestep);
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
  Dstates = zeros(size(Cstates,1), size(D,2));
  Dtot = [Dstates; D];
  
  Ninputs = size(B,2);
  Noutputs = size(C,1);
  Nss = size(A,1);
  NssOut = size(Cstates,1);
  
  %% collecting data before saving in loop
  aos = ao.initObjectWithSize(Noutputs+NssOut, Ninputs);
  myinfo = getInfo('None');
  inhist = sys.hist;
  
  inputType = find(pl, 'response');
  
  
  for ii=1:Ninputs
    sys_ss = ss(A, B(:,ii), [Cstates; C], Dtot(:,ii), Ts);
    
    %% depending on user option, compute response for one input only
    if strcmpi( inputType, 'IMPULSE')
      Y = impulse(sys_ss, 1:Ts:(timeMax*Ts));
    elseif strcmpi( inputType, 'STEP')
      Y = step(sys_ss,  1:Ts:(timeMax*Ts));
    else
      error(['Option ''response'' does not accept the value' inputType]);
    end
    
    %% storing responsei in aos for one input only
    
    for oo=1:NssOut;
      aos(oo,ii).setData((tsdata( Y(:,oo), 1/Ts)));
      aos(oo,ii).setName([sys.inputs(1).ports(ii).name '->' sys.outputs(1).ports(oo).name]);
      aos(oo,ii).setXunits(unit.seconds);
      aos(oo,ii).setYunits(sys.outputs(1).ports(oo).units);
      aos(oo,ii).setDescription([inputType ' response from input ' , sys.inputs(1).ports(ii).name , 'to output ',  sys.outputs(1).ports(oo).name]);
      aos(oo,ii).setT0(sys.timestep);
      aos(oo,ii).addHistory(myinfo, pl , {''}, inhist );
    end
    for oo=1:Noutputs;
      aos(NssOut+oo,ii).setData(tsdata( Y(:,NssOut+oo), 1/Ts));
      aos(NssOut+oo,ii).setName([sys.inputs(1).ports(ii).name '->' sys.outputs(2).ports(oo).name]);
      aos(NssOut+oo,ii).setXunits(unit.seconds);
      aos(NssOut+oo,ii).setYunits(sys.outputs(2).ports(oo).units);
      aos(NssOut+oo,ii).setDescription([inputType ' response from input ' , sys.inputs(1).ports(ii).name , 'to output ',  sys.outputs(2).ports(oo).name]);
      aos(NssOut+oo,ii).setT0(sys.timestep);
      aos(NssOut+oo,ii).addHistory(myinfo, pl , {''}, inhist );
    end
  end
  
  %% Set output depending on nargout
  if nargout == numel(aos)
    for jj=1:nargout
      varargout{jj} = aos(jj);
    end
  elseif nargout == 1;
    varargout{1} = aos;
  elseif nargout == 0;
    iplot(aos);
  else
    error('Wrong number of outputs')
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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

