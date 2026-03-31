% PARAMETERDIFF Makes a ssm that produces the output and state derivatives.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARAMETERDIFF Makes a ssm that produces the output 
%              and state derivative in regard with specified parameters, for a specificed variation.
%
% CALL:        obj = obj.parameterDiff({'key1', ...}, [val1, ...]);
%              obj = obj.parameterDiff(plist);
%              obj = obj.parameterDiff('key', val);
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'parameterDiff')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = parameterDiff(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin, in_names{ii} = inputname(ii); end
  
  % Collect all SSMs and options
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %%% Internal call: Only one object + don't look for a plist
  internal = utils.helper.callerIsMethod();
  
  %% processing input
  names = pl.find('names');
  if ischar(names)
    names = {names};
  elseif ~iscellstr(names)
    error('### Parameter names must be a cell-array of strings')
  end
  
  values = pl.find('values');
  if ~isa(values, 'double')
    error('### param values should be a double')
  end
  
  Nsys     = numel(sys);
  sys_out  = ssm.initObjectWithSize(Nsys,1);
  
  %% checking data
  Ndiff = length(names);
  if ~(Ndiff== length(values))
    error(['### The number of parameter names is ' num2str(Ndiff) ' and the number of parameter values is ' num2str(length(values))]);
  end
  if ~isa(values, 'double')
    error(['### Parameter ''values'' is not a double array but of class ' class(values)]);
  end
  
  for i_sys = 1:Nsys
    %% getting matrix sizes
    Nss = sys(i_sys).Nstates;
    Ninputs = sys(i_sys).Ninputs;
    Noutputs = sys(i_sys).Noutputs;
    sssizes = sys(i_sys).statesizes;
    inputsizes = sys(i_sys).inputsizes;
    outputsizes = sys(i_sys).outputsizes;
    
    %% setting matrix sizes
    amats = cell(Nss*(Ndiff+1), Nss*(Ndiff+1));
    bmats = cell(Nss*(Ndiff+1), Ninputs);
    cmats = cell(Noutputs*(Ndiff+1), Nss*(Ndiff+1));
    dmats = cell(Noutputs*(Ndiff+1), Ninputs);
    sys_num = sys(i_sys).subsParameters;
    
    %% assigning system matrices for nominal values
    amats(1:Nss,1:Nss) = sys_num.amats;
    bmats(1:Nss,1:Ninputs) = sys_num.bmats;
    cmats(1:Noutputs,1:Nss) = sys_num.cmats;
    dmats(1:Noutputs,1:Ninputs) = sys_num.dmats;
    
    outputs = sys(i_sys).outputs;
    states = sys(i_sys).states;
    
    %% loop over parameters
    for i_p = 1:Ndiff
      % computing ssm derivative
      sys_loc = copy(sys(i_sys), true);
      value_loc = sys(i_sys).params.find(names{i_p}) + values(i_p);
      sys_loc.doSetParameters(names(i_p), value_loc);
      sys_loc.subsParameters;
      
      % computing derivatives of matrices
      dAmats = ssm.blockMatRecut( ( ssm.blockMatFusion(sys_loc.amats, sssizes, sssizes) - ssm.blockMatFusion(sys_num.amats, sssizes, sssizes) )/ values(i_p) ,  sssizes, sssizes);
      dBmats = ssm.blockMatRecut( ( ssm.blockMatFusion(sys_loc.bmats, sssizes, inputsizes) - ssm.blockMatFusion(sys_num.bmats, sssizes, inputsizes) )/ values(i_p) ,  sssizes, inputsizes);
      dCmats = ssm.blockMatRecut( ( ssm.blockMatFusion(sys_loc.cmats, outputsizes, sssizes) - ssm.blockMatFusion(sys_num.cmats, outputsizes, sssizes) )/ values(i_p) ,  outputsizes, sssizes);
      dDmats = ssm.blockMatRecut( ( ssm.blockMatFusion(sys_loc.dmats, outputsizes, inputsizes) - ssm.blockMatFusion(sys_num.dmats, outputsizes, inputsizes) )/ values(i_p) ,  outputsizes, inputsizes);
      
      % assigning matrices for derivatives
      amats( (1+i_p*Nss):((i_p+1)*Nss), (1+i_p*Nss):((i_p+1)*Nss) ) = sys_num.amats;
      amats( (1+i_p*Nss):((i_p+1)*Nss), 1:Nss ) = dAmats;
      bmats( (1+i_p*Nss):((i_p+1)*Nss), 1:Ninputs ) = dBmats;
      cmats( (1+i_p*Noutputs):((i_p+1)*Noutputs), (1+i_p*Nss):((i_p+1)*Nss) ) = sys_num.cmats;
      dmats( (1+i_p*Noutputs):((i_p+1)*Noutputs), 1:Ninputs ) = dDmats;
      cmats( (1+i_p*Noutputs):((i_p+1)*Noutputs), 1:Nss ) = dCmats;
      
      % assigning outputs
      outputs((1+i_p*Noutputs):((i_p+1)*Noutputs)) = sys_loc.outputs ;
      % renaming outputs
      for i=(1+i_p*Noutputs):((i_p+1)*Noutputs)
        outputs(i).setBlockNames( [outputs(i).name '_DIFF_' names{i_p}] );
      end
      
      % assigning states
      states((1+i_p*Nss):((i_p+1)*Nss)) = sys_loc.states ;
      % renaming states
      for i=(1+i_p*Nss):((i_p+1)*Nss)
        states(i).setBlockNames( [states(i).name '_DIFF_' names{i_p}] );
      end
      
      clear sys_loc
    end
    
    %% proceeding parameters update
    sys_out(i_sys).amats = amats;
    sys_out(i_sys).bmats = bmats;
    sys_out(i_sys).cmats = cmats;
    sys_out(i_sys).dmats = dmats;
    sys_out(i_sys).timestep = sys(i_sys).timestep;
    sys_out(i_sys).name = sys(i_sys).name;
    sys_out(i_sys).description = sys(i_sys).description;
    sys_out(i_sys).params = plist;
    sys_out(i_sys).outputs = outputs;
    sys_out(i_sys).inputs = sys(i_sys).inputs;
    sys_out(i_sys).states = states;
    
    sys_out(i_sys).validate;
    
    %% history and output arguments
    if ~internal
      sys_out(i_sys).addHistory(ssm.getInfo(mfilename), pl , {''}, sys(i_sys).hist );
    end
  end
  
  if nargout == numel(sys_out)
    for ii = 1:numel(sys_out)
      varargout{ii} = sys_out(ii);
    end
  else
    varargout{1} = sys_out;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'names', 'A cell-array of parameter names for numerical differentiations.'}, {});
  pl.append(p);
  
  p = param({'values', 'An array of parameter values for numerical step size.'}, []);
  pl.append(p);
end
