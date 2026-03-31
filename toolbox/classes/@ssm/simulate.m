% SIMULATE simulates a discrete ssm with given inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMULATE simulates a discrete ssm with given inputs.
%
% CALL:
%         mat_out = simulate(sys, pl)
%
% INPUTS:
%         sys - an ssm object
%
% OUTPUTS:
%          mat_out - returns a matrix object of AOs, one for each specified
%                    model output.
%
% HINT: to run a noise simulation with a fixed noise state, set the random
% number generate seed to a known fixed value before calling ssm/simulate.
% This will ensure that the output of simulate is the same each time you
% call it for a given setup. For example:
%
%     rng(0) % set seed to a fixed value (0)
%     out1 = simulate(mdl, pl) % simulate
%     out2 = simulate(mdl, pl) % simulate the same noise again
%
%
% The procinfo of the matrix object contains the last state of the
% simulation under the key 'LASTX'.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'simulate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TO DO:  options to be defined (NL case)
% allow use of other LTPDA functions to generate white noise


function varargout = simulate(varargin)
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(utils.const.msg.PROC3, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  % Get plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % begin function body
  tini = pl.find('t0');
  if isa(tini, 'double')
    tini = time(tini);
  elseif ischar(tini)
    tini = time(tini);
  end
  
  % retrieve system infos
  if numel(sys) ~= 1
    error('simulate needs exactly one ssm as an input')
  end
  
  if ~sys.isnumerical
    error(['error because system ',sys.name,' is not numerical']);
  end
  
  timestep  = sys.timestep;
  if timestep == 0
    error('timestep should not be 0 in simulate!!')
  end
  
  if callerIsMethod
    % we don't need the history of the input
  else
    inhist  = sys.hist;
  end
  
  if pl.isparam('noise variable names')
    error('The noise option used must be split between "covariance" and "cpsd". "noise variable names" does not exist anymore!')
  end
  
  % display time ?
  displayTime = utils.prog.yes2true(find(pl, 'displayTime'));
  
  % initial state
  ssini = find(pl,'ssini');
  if isempty(ssini)
    initialize = find(pl, 'initialize');
    if initialize
      ssini = sys.steadyState(pl);
      ssini = find(ssini, 'state');
    else
      ssini = cell(sys.Nss, 1);
      for ii = 1:sys.Nss
        ssini{ii} = zeros(sys.sssizes(ii), 1);
      end
    end
  end
  ssSizesIni = sys.statesizes;
  SSini = double(ssm.blockMatFusion(ssini, ssSizesIni, 1));
  
  % collecting simulation i/o data
  
  % values
  aos_in = find(pl, 'aos');
  constants_in = find(pl, 'constants');
  cov_in = find(pl, 'covariance');
  cpsd_in = find(pl, 'CPSD');
  noise_in = blkdiag(cov_in, cpsd_in/(timestep*2));
  [U1,S1,V1] = svd(noise_in.');
  if (sum(S1 < 0) > 0)
    error('Covariance matrix is not positive definite')
  end
  noise_mat = U1*sqrt(S1);
  
  % modifying system's ordering
  if find(pl, 'reorganize')
    reorgPlist = ssm.getInfo('reorganize', 'for simulate').plists;
    sys = reorganize(sys, subset(pl.pset('set', 'for simulate'), reorgPlist.getKeys));
  end
  
  % getting system's i/o sizes
  inputSizes = sys.inputsizes;
  outputSizes = sys.outputsizes;
  
  Naos_in = inputSizes(1);
  Nnoise = inputSizes(2);
  Nconstants = inputSizes(3);
  NstatesOut = outputSizes(1);
  NoutputsOut = outputSizes(2);
  
  if numel(aos_in) ~= Naos_in
    error(['There are ' num2str(numel(aos_in)) ' input aos and ' num2str(Naos_in) ' corresponding inputs indexed.' ])
  elseif numel(diag(noise_in)) ~= Nnoise
    error(['There are ' num2str(numel(diag(noise_in))) ' input noise variances and ' num2str(Nnoise) ' corresponding inputs indexed.' ])
  elseif numel(constants_in) ~= Nconstants
    error(['There are ' num2str(numel(constants_in)) ' input constants and ' num2str(Nconstants) ' corresponding inputs indexed.' ])
  end
  
  A        = sys.amats{1, 1};
  Coutputs = sys.cmats{2, 1};
  Cstates  = sys.cmats{1, 1};
  Baos     = sys.bmats{1, 1};
  Daos     = sys.dmats{2, 1};
  Bnoise   = sys.bmats{1, 2} * noise_mat;
  Dnoise   = sys.dmats{2, 2} * noise_mat;
  Bcst     = sys.bmats{1, 3} * reshape(constants_in, Nconstants, 1);
  Dcst     = sys.dmats{2, 3} * reshape(constants_in, Nconstants, 1);
  
  % getting correct number of samples
  Nsamples = find(pl, 'Nsamples');
  f0 = 1/timestep;
  for ii = 1:Naos_in
    
    Nsamples = min(Nsamples, length(aos_in(ii).y));
    
    % Check this AO has the correct sample frequency
    if ~(f0 == aos_in(ii).fs)
      str = ['WARNING : ssm frequency is ', num2str(f0),...
        ' but sampling frequency of ao named ',...
        aos_in(ii).name, ' is ', num2str(aos_in(ii).fs) ];
      utils.helper.msg(utils.const.msg.MNAME, str);
    end
    
    % maybe tdata should be retrieved and verified to be equal, rather than this.
  end
  if Nsamples == inf % case there is no input!
    error('warning : no input option ''Nsamples'' providing simulation duration is available!!')
  end
  
  % termination condition
  if strcmp(find(pl, 'termincond'),'');
    doTerminate = false;
    terminationCond = '';
  else
    doTerminate = true;
    terminationCond = find(pl, 'termincond');
  end
  
  % ao vector
  aos_vect = zeros(Naos_in, Nsamples);
  time_vect = [];
  toffset = 0;
  for jj = 1:Naos_in
    aos_vect(jj, :) = aos_in(jj).y(1:Nsamples).';
    if ~aos_in(1).data.evenly
      time_vect = aos_in(1).x(1:Nsamples);
    else
      toffset = aos_in(1).toffset;
    end
    if tini.double == 0
      tini = aos_in(1).t0;
    end
  end
  
  % simulation loop
  [x, y, lastX] = ssm.doSimulate(...
    SSini, Nsamples, ...
    A, Baos, Coutputs, Cstates, Daos, Bnoise, Dnoise, Bcst, Dcst,...
    aos_vect, doTerminate, terminationCond, displayTime, timestep, pl.find('force complete'));
  
  % saving in aos
  fs      = 1/timestep;
  isysStr = sys.name;
  
  ao_out = ao.initObjectWithSize(1, NstatesOut + NoutputsOut);
  for ii = 1:NstatesOut
    if isempty(time_vect)
      % Build the time base based on input data properties
      out_data = tsdata(x(ii,:), fs, tini);
      out_data.setToffset(1000*toffset);
    else
      % Inherit the time base from the first input ao
      out_data = tsdata(time_vect, x(ii,:), tini);
    end
    ao_out(ii).setData(out_data);
    ao_out(ii).setName(sys.outputs(1).ports(ii).name);
    ao_out(ii).setXunits(unit.seconds);
    ao_out(ii).setYunits(sys.outputs(1).ports(ii).units);
    ao_out(ii).setDescription(...
      ['simulation for ' isysStr, ' : ',  sys.outputs(1).ports(ii).name,...
      '    ' sys.outputs(1).ports(ii).description]);
  end
  
  for ii = 1:NoutputsOut
    if isempty(time_vect)
      % Build the time base based on input data properties
      out_data = tsdata(y(ii,:), fs, tini);
      out_data.setToffset(1000*toffset);
    else
      % Inherit the time base from the first input ao
      out_data = tsdata(time_vect, y(ii,:), tini);
    end
    ao_out(NstatesOut+ii).setData(out_data);
    ao_out(NstatesOut+ii).setName(sys.outputs(2).ports(ii).name);
    ao_out(NstatesOut+ii).setXunits(unit.seconds);
    ao_out(NstatesOut+ii).setYunits(sys.outputs(2).ports(ii).units);
    ao_out(NstatesOut+ii).setDescription(...
      ['simulation for, ' isysStr, ' : ',  sys.outputs(2).ports(ii).name, ...
      '    ', sys.outputs(2).ports(ii).description]);
  end
  
  % construct output matrix object
  out = matrix(ao_out);
  out.procinfo = plist('lastX', ssm.blockMatRecut(lastX,ssSizesIni, 1));
  
  if callerIsMethod
    % do nothing
  else
    myinfo = getInfo('None');
    out.addHistory(myinfo, pl , ssm_invars(1), inhist);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
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
  
  pl = copy(ssm.getInfo('reorganize', 'for simulate').plists,1);
  pl.remove('set');
  
  p = param({'covariance', 'The covariance of this noise between input ports for the <i>time-discrete</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'CPSD', 'The one sided cross-psd of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'An array of input AOs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'constants', 'Array of DC values for the different corresponding inputs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'Nsamples', 'The maximum number of samples to simulate (AO length(s) overide this).'}, paramValue.DOUBLE_VALUE(inf));
  pl.append(p);
  
  p = param({'ssini', 'A cell-array of vectors that give the initial position for simulation.'}, {});
  pl.append(p);
  
  p = param({'initialize', 'When set to 1, a random state value is computed for the initial point.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'tini', 'Same as t0; kept for backwards compatibility.'}, paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({'t0', 'The initial simulation time (seconds).'}, paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({'displayTime', 'Switch on/off the display'},  paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'termincond', 'A string to evaluate a termination condition on the states in x (''lastX'') or outputs in y (''lastY'')'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'force complete', 'Force the use of the complete simulation code.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

