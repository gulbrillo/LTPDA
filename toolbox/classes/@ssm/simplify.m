% SIMPLIFY enables to do model simplification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% DESCRIPTION: SIMPLIFY allows you to eliminate input/state/output variables.
%
% CALL:        [ssm] = SIMPLIFY(ssm, pl);
%
% INPUTS :
%             ssm     - a ssm object
%                  pl - an option plist
%
% OPTIONS :
% plist with parameters 'inputs', 'states' and 'outputs' to indicate which
% inputs, states and outputs variables are taken in account. This requires
% proper variable naming. If a variable called appears more that once it
% will be used once only.
%
% OUTPUTS:
%           The output array are of size Nsys*Noptions
%           sys_out -  (array of) ssm objects without the specified information
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'simplify')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplify(varargin)
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  %% starting initial checks
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSMs and plists
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist);
  
  Nsys     = numel(sys);
  if Nsys ~= 1
    error('### Please input (only) one SSM model');
  end
  
  % Decide on a deep copy or a modify, depending on the output
  sys = copy(sys, nargout);
  
  %% begin function body
  
  % Loop over input systems
  for i_sys=1:Nsys
    doSimplify(sys(i_sys), pl);
    %% updating size fields
    sys(i_sys).addHistory(ssm.getInfo(mfilename), pl , ssm_invars(i_sys), sys(i_sys).hist );
    %% checking system has some inputs and outputs left
    if sys(i_sys).Ninputs == 0
      error('The ssm object has no inputs, which is not allowed!')
    elseif sys(i_sys).Noutputs == 0
      error('The ssm object has no outputs, which is not allowed!')
    end
  end
  
  if nargout == numel(sys)
    for ii = 1:numel(sys)
      varargout{ii} = sys(ii);
    end
  else
    varargout{1} = sys;
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
  pl = plist();
  
  p = param({'inputs', ['Specify the inputs. Give one of:<ul>'...
                        '<li>A cell-array of input port names.</li>'...
                        '<li>A cell-array of logical arrays specifying which input ports to use for each input block.</li>'...
                        '<li>A cell-array of double values specifying which input ports to use for each input block.<li>'...
                        '<li>The string ''ALL'' to use all inputs.']}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
  
  p = param({'states', 'Specify the states. Specify the states as for the ''inputs'' parameter.'}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
  
  p = param({'outputs', 'Specify the outputs. Specify the outputs as for the ''inputs'' parameter.'}, paramValue.STRING_VALUE('ALL'));
  pl.append(p);
  
end

