% KALMAN applies Kalman filtering to a discrete ssm with given i/o
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: KALMAN applies Kalman filtering to a discrete ssm with
%              given i/o.
% CALL: [mat_out pl_out] = kalman(sys, plist_inputs)
%
% INPUTS:
%         - sys, (array of) ssm object
%
% OUTPUTS:
%          _ mat_out contains specified returned aos
%          _ pl_out contains 'lastX', the last state position
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'kalman')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = kalman(varargin)
  
  %% starting initial checks
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %% retrieve system infos
  if ~all(sys.isnumerical)
    error(['error because system ', sys.name, ' is not numerical']);
  end
  timestep = sys.timestep;
  if timestep==0
    error('timestep should not be 0 in simulate!!')
  end
  if ~callerIsMethod
    inhist  = sys(:).hist;
  end
  if pl.isparam('white noise variable names')
    error('The noise option used must be split between "covariance" and "cpsd". "noise variable names" does not exist anymore!')
  end
  
  %% display time ?
  displayTime = find(pl, 'displayTime');
  
  %% initial state
  ssini = find(pl,'ssini');
  if isempty(ssini)
    ssini = cell(sys.Nss,1);
    for i=1:sys.Nss
      ssini{i} = zeros(sys.sssizes(i),1);
    end
  end
  ssSizesIni = sys.statesizes;
  ssini = ssm.blockMatFusion(ssini,ssSizesIni,1);
  
  %% modifying system's ordering
  if find(pl, 'reorganize')
    sys = sys.reorganize(pl, plist('set', 'for kalman'));
  end
  sys_est = sys(1);
  sys_exp = sys(2);
  
  %% getting system's i/o sizes
  Naos_in = sys_est.inputsizes(1);
  Nnoise = sys_est.inputsizes(2);
  Nconstants = sys_est.inputsizes(3);
  NstatesOut = sys_est.outputsizes(1);
  NoutputsOut = sys_est.outputsizes(2);
  Nknown = sys_exp.outputsizes(2);
  
  aos_in = find(pl, 'aos');
  known_out = find(pl, 'known outputs');
  constants_in = find(pl, 'constants');
  cov_in = find(pl, 'covariance');
  cpsd_in = find(pl, 'CPSD');
  noise_in = blkdiag(cov_in, cpsd_in/(timestep*2));
  
  if numel(aos_in)~=Naos_in
    error(['There are ' num2str(numel(aos_in)) ' input aos and ' num2str(Naos_in) ' corresponding inputs indexed.' ])
  elseif numel(known_out)~=Nknown
    error(['There are ' num2str(numel(known_out)) ' known output aos and ' num2str(Nknown) ' corresponding inputs indexed.' ])
  elseif numel(diag(noise_in))~=Nnoise
    error(['There are ' num2str(numel(noise_in)) ' input noise variances and ' num2str(Naos_in) ' corresponding inputs indexed.' ])
  elseif numel(constants_in)~=Nconstants
    error(['There are ' num2str(numel(constants_in)) ' input constants and ' num2str(Nconstants) ' corresponding inputs indexed.' ])
  end
  [U1,S1,V1] = svd(noise_in.'); %#ok<NASGU>
  noise_mat = U1*sqrt(S1)/sqrt(timestep*2);
  
  A        = sys_est.amats{1,1};
  Cstates  = sys_est.cmats{1,1};
  Coutputs = sys_est.cmats{2,1};
  Baos     = sys_est.bmats{1,1};
  Daos     = sys_est.dmats{2,1};
  Bnoise   = sys_est.bmats{1,2}*noise_mat;
  %   Dnoise   = sys_est.dmats{1,2}*noise_mat;
  Bcst     = sys_est.bmats{1,3};
  Dcst     = sys_est.dmats{2,3};
  
  CoutputsK = sys_exp.cmats{2,1};
  DaosK     = sys_exp.dmats{2,1};
  DnoiseK   = sys_exp.dmats{2,2}*noise_mat;
  DcstK     = sys_exp.dmats{2,3};
  
  %% getting correct number of samples
  Nsamples = find(pl, 'Nsamples');
  f0 = 1/timestep;
  for i=1:Naos_in
    Nsamples = min(Nsamples,length(aos_in(i).y));
    try
      if ~(f0==aos_in(i).fs)
        str = ['WARNING : ssm frequency is ',num2str(f0),...
          ' but sampling frequency of ao named ',...
          aos_in(i).name, ' is ', num2str(aos_in(i).fs) ];
        utils.helper.msg(utils.const.msg.MNAME, str);
      end
    end
    % maybe tdata should be retrieved and verified to be equal, rather than this.
  end
  for i=1:Nknown
    Nsamples = min(Nsamples,length(known_out(i).y));
    try
      if ~(f0==known_out(i).fs)
        str = ['WARNING : ssm frequency is ',num2str(f0),...
          ' but sampling frequency of ao named ',...
          aos_in(i).name, ' is ', num2str(aos_in(i).fs) ];
        utils.helper.msg(utils.const.msg.MNAME, str);
      end
    end
    % maybe tdata should be retrieved and verified to be equal, rather than this.
  end
  if Nsamples == inf % case there is no input!
    display('warning : no input providing simulation duration is available!!')
    Nsamples = 0;
  end
  
  %% evaluating Kalman feedback K, innovation gain M, state covariance P, output covariance Z
  % given Q and R (process and measurement noise covariances)
  Qn = Bnoise*noise_in*transpose(Bnoise);
  Qn = (Qn + 1e-10*norm(Qn)*eye(size(Qn)));
  Rn = DnoiseK*noise_in*transpose(DnoiseK);
  Rn = Rn + 1e-10*norm(Rn)*eye(size(Rn));
  %   Nn = Bnoise*noise_in*transpose(Dnoise);
  P = eye(size(A))*1e20;
  for i=1:10000
    P = A*P*A'+Qn;
    K = P*CoutputsK'*(CoutputsK*P*CoutputsK'+Rn)^-1;
    P = (eye(size(A)) - K*CoutputsK)*P;
  end
  Z = Coutputs*P*Coutputs' + Rn;
  
  %% constant vector
  constants_vectX = Bcst*constants_in;
  constants_vectY = Dcst*constants_in;
  constants_vectYKnown = DcstK*constants_in;
  
  %% ao vector
  aos_vect = zeros(Naos_in, Nsamples);
  for j = 1:Naos_in
    aos_vect(j,:) = aos_in(j).y(1:Nsamples).';
  end
  Y_in = zeros(Nknown, Nsamples);
  for j=1:Nknown
    Y_in(j,:) = reshape( known_out(j).y(1:Nsamples), 1, [] ).';
  end
  
  %% rewriting fields to ssm/doSimulate
  
  A_kalman = A - K*Coutputs*A;
  Baos_kalman = [ Baos - K*CoutputsK*Baos - K*DaosK   K];
  aos_vect_kalman = [aos_vect; Y_in ];
  Bcst_kalman = constants_vectX - K*constants_vectYKnown - K*CoutputsK*constants_vectX;
  Coutputs_kalman = [Cstates ; Coutputs];
  Dcst_kalman = [zeros(size(Cstates,1),1) ; constants_vectY];
  Daos_kalman = [...
    zeros(size(Cstates,1), size(Daos,2))   zeros(size(Cstates,1), size(K,2)) ;...
    Daos                                   zeros(size(Daos,1), size(K,2))];
  Cstates_kalman = zeros(0, size(A,2));
  Bnoise_kalman = zeros(size(A,1), 0);
  Dnoise_kalman = zeros(size(Coutputs_kalman,1), 0);
  
  %% call to doSimulate
  doTerminate = false;
  terminationCond = false;
  forceComplete = false;
  
  [x, y, lastX] = ssm.doSimulate(ssini, Nsamples-1, ...
    A_kalman, Baos_kalman, Coutputs_kalman, Cstates_kalman, Daos_kalman, Bnoise_kalman, Dnoise_kalman, ...
    Bcst_kalman, Dcst_kalman, aos_vect_kalman, doTerminate, terminationCond, displayTime, timestep, forceComplete);
  
  y = [Coutputs_kalman*lastX y];
  
  %% saving in aos
  fs     = 1/timestep;
  isysStr = sys.name;
  tini = find(pl, 'tini');
  if isa(tini,'double')
    tini = time(tini);
  end
  
  ao_out = ao.initObjectWithSize(1, NoutputsOut + NstatesOut);
  for ii=1:NstatesOut
    ao_out(ii).setData(tsdata( y(ii,:), fs));
    ao_out(ii).setName(['kalman estimate of ' sys_est.outputs(1).ports(ii).name]);
    ao_out(ii).setXunits(unit.seconds);
    ao_out(ii).setYunits(sys_est.outputs(1).ports(ii).units);
    ao_out(ii).setDescription(...
      ['Kalman estimate for ' isysStr, ' : ',  sys_est.outputs(1).ports(ii).name,...
      '    ' sys_est.outputs(1).ports(ii).description]);
    ao_out(ii).setT0(tini);
  end
  for ii=1:NoutputsOut
    ao_out(NstatesOut+ii).setData(tsdata( y(NstatesOut+ii,:), fs));
    ao_out(NstatesOut+ii).setName(['kalman estimate of ' sys_est.outputs(2).ports(ii).name]);
    ao_out(NstatesOut+ii).setXunits(unit.seconds);
    ao_out(NstatesOut+ii).setYunits(sys_est.outputs(2).ports(ii).units);
    ao_out(NstatesOut+ii).setDescription(...
      ['Kalman estimate for ' isysStr, ' : ',  sys_est.outputs(2).ports(ii).name, ...
      '    ' sys_est.outputs(2).ports(ii).description]);
    ao_out(NstatesOut+ii).setT0(tini);
  end
  
    %% construct output matrix object
  out = matrix(ao_out);
  if callerIsMethod
    % do nothing
  else
    myinfo = getInfo('None');
    out.addHistory(myinfo, pl , ssm_invars(1), inhist );
  end
  
  %% construct output analysis object
  plist_out = plist('process covariance', Qn, 'readout covariance', Rn, ...
    'state covariance', P, 'output covariance', Z, 'Kalman gain', K );
  
  %% Set output depending on nargout
  if nargout == 1;
    varargout = {out};
  elseif nargout == 2;
    varargout = {out plist_out};
  elseif nargout == 0;
    iplot(ao_out);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = ssm.getInfo('reorganize', 'for kalman').plists;
  pl.remove('set');
  
  p = param({'covariance', 'The covariance of this noise between input ports for the <i>time-discrete</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'CPSD', 'The one sided cross-psd of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'An array of input AOs (experimental stimuli).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'constants', 'Array of DC values for the different corresponding inputs.'}, paramValue.DOUBLE_VALUE(zeros(0,1)));
  pl.append(p);
  
  p = param({'known outputs', 'Array of AOs for the different corresponding outputs (experiment measurements).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'Nsamples', 'The maximum number of samples to simulate (AO length(s) overide this).'}, paramValue.DOUBLE_VALUE(inf));
  pl.append(p);
  
  p = param({'ssini', 'A cell-array of vectors that give the initial position for simulation.'}, {});
  pl.append(p);
  
  p = param({'tini', 'The initial filtering time (seconds).'}, paramValue.DOUBLE_VALUE(0) );
  pl.append(p);
  
  p = param({'displayTime', 'Switch off/on the display'},  paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'force complete', 'Force the use of the complete simulation code.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  
end

