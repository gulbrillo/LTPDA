% REOGANIZE rearranges a ssm object for fast input to BODE, SIMULATE, PSD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: rearranges a ssm object for fast input to BODE, SIMULATE, PSD.
%
% CALL:    sys = reshuffle(sys, plist)
%
% INPUTS:
%         'sys'      - ssm object
%         'plist'    - plist object
%
%  The inputs/states/outputs can only be indexed using a cellstr containing
%  block names or port names.
%  Then the object can be passed to BODE, SIMULATE, PSD, CPSD, RESP with
%  the option "rearrange" turned to "false". These functions will run
%  significantly faster.
%
% OUTPUTS:
%
%        'sys' - a ssm object.
%
%  <a href="matlab:utils.helper.displayMethodInfo('ssm', 'reorganize')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = reorganize(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod; 
  
  utils.helper.msg(utils.const.msg.PROC3, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pli, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pli = pli.combine(plist(rest{:}));
  end
  
  if numel(sys)~=1
    error(['There should be only one input object to ' mfilename])
  end
    
  % Apply default plist
  set = pli.find('set');
  pli = applyDefaults(getDefaultPlist(set), pli);
  
  sys = copy(sys, nargout);
  
  switch(lower(set))
    case 'none'
      error('the options "set" HAS to be specified');
    case 'for bode'
      inputnames = pli.find('inputs');
      statenames = pli.find('states');
      outputnames = pli.find('outputs');
      sys.reshuffle(inputnames, {}, {},  'ALL', outputnames, statenames);
    case 'for resp'
      inputnames = pli.find('inputs');
      statenames = pli.find('states');
      outputnames = pli.find('outputs');
      sys.reshuffle( inputnames, {}, {},  'ALL', outputnames, statenames);
    case 'for simulate'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'covariance variable names');
      cpsd_varnames = find(pli, 'CPSD variable names');
      constants_varnames = find(pli, 'constant variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      sys.reshuffle( aos_varnames, [cov_varnames cpsd_varnames], constants_varnames,  'ALL', return_outputs, return_states );
    case 'for kalman'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'covariance variable names');
      cpsd_varnames = find(pli, 'cpsd variable names');
      constants_varnames = find(pli, 'constant variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      known_outputs = find(pli, 'known output variable names');
      sys_est = copy(sys,true);
      sys_exp = copy(sys,true);
      sys_est = reshuffle(sys_est, aos_varnames, [cov_varnames cpsd_varnames], constants_varnames,  'ALL', return_outputs, return_states );
      sys_exp = reshuffle(sys_exp, aos_varnames, [cov_varnames cpsd_varnames], constants_varnames,  'ALL', known_outputs, 'none' );
      sys = [sys_est sys_exp];
    case 'for cpsd'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'covariance variable names');
      cpsd_varnames = find(pli, 'CPSD variable names');
      PZmodels_varnames = find(pli, 'PZmodel variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      sys.reshuffle( aos_varnames, [cov_varnames cpsd_varnames], PZmodels_varnames,  'ALL', return_outputs, return_states );
    case 'for psd'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'variance variable names');
      cpsd_varnames = find(pli, 'PSD variable names');
      PZmodels_varnames = find(pli, 'PZmodel variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      sys.reshuffle( aos_varnames, [cov_varnames cpsd_varnames], PZmodels_varnames,  'ALL', return_outputs, return_states );
    case 'for cpsdforcorrelatedinputs'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'covariance variable names');
      cpsd_varnames = find(pli, 'CPSD variable names');
      PZmodels_varnames = find(pli, 'PZmodel variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      sys.reshuffle( aos_varnames, [cov_varnames cpsd_varnames], PZmodels_varnames,  'ALL', return_outputs, return_states );
    case 'for cpsdforindependentinputs'
      aos_varnames = find(pli, 'aos variable names');
      cov_varnames = find(pli, 'variance variable names');
      cpsd_varnames = find(pli, 'PSD variable names');
      PZmodels_varnames = find(pli, 'PZmodel variable names');
      return_states = find(pli, 'return states');
      return_outputs = find(pli, 'return outputs');
      sys.reshuffle( aos_varnames, [cov_varnames cpsd_varnames], PZmodels_varnames,  'ALL', return_outputs, return_states );
    case 'none'
      error('please set the parameter "set"')
    otherwise
      error('unknown parameter "set"')
  end
  
  if ~callerIsMethod
    for i_sys = 1:numel(sys)
      sys(i_sys).addHistory(getInfo('None'), pli, ssm_invars, sys(i_sys).hist ); 
    end  
  end
  
  sys.validate;
  % Set output
  varargout = utils.helper.setoutputs(nargout, sys);
end


%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = getSets;
    pl = plist.initObjectWithSize(1,numel(sets));
    for i=1:numel(sets)
      pl(i)   = getDefaultPlist(sets{i});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

function sets = getSets
  sets = {'For bode', 'For simulate', 'For kalman', 'For cpsd', 'For resp', ...
    'For psd', 'for cpsdforindependentinputs', 'for cpsdforcorrelatedinputs'};
end

function pl = getDefaultPlist(set)
  sets = lower(getSets);
  if ~utils.helper.ismember(sets, lower(set))
    error('### Unknown set [%s]', set);
  end
  
  pl = plist();
  
  p = param({'set','Choose for which operation the ssm iois re-organized is done'},...
    {7, getSets, paramValue.SINGLE});
  pl.append(p);
  
  switch lower(set) % Select parameter set
    case 'for bode'
      p = param({'inputs', 'A cell-array of input ports and blocks.'}, 'ALL' );
      pl.append(p);
      p = param({'outputs', 'A cell-array of output ports and blocks.'}, 'ALL' );
      pl.append(p);
      p = param({'states', 'A cell-array of states ports and blocks.'}, 'NONE' );
      pl.append(p);
    case 'for simulate'
      p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input port names corresponding to the different input AOs.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('ao names');
      p.addAlternativeKey('ao port names');
      pl.append(p);
      p = param({'constant variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
    case 'for kalman'
      p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input port names corresponding to the different input AOs.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('ao names');
      p.addAlternativeKey('ao port names');
      pl.append(p);
      p = param({'constant variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
      p = param({'known output variable names', 'A cell-array of strings of the known output variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
    case 'for cpsd'
      p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
    case 'for resp'
      p = param({'inputs', 'A cell-array of input ports and blocks.'}, 'ALL' );
      pl.append(p);
      p = param({'outputs', 'A cell-array of output ports and blocks.'}, 'ALL' );
      pl.append(p);
      p = param({'states', 'A cell-array of states ports and blocks.'}, 'NONE' );
      pl.append(p);
    case 'for psd'
      p = param({'variance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
    case 'for cpsdforindependentinputs'
      p = param({'variance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
    case 'for cpsdforcorrelatedinputs'
      p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
      pl.append(p);
      p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('outputs');
      pl.append(p);
  end
end
