% OPTIMISEFORFITTING reduces the system matrices to doubles and strings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% DESCRIPTION: OPTIMISEFORFITTING reduces the system matrices to doubles
%              and strings.
%
% CALL:        [ssm] = optimiseForFitting(ssm, pl);
%
% INPUTS :
%             ssm     - a ssm object
%                  pl - an option plist
%
%
% OUTPUTS:
%           The output array are of size Nsys*Noptions
%           sys_out -  (array of) ssm objects without the specified information
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'simplify')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = optimiseForFitting(varargin)
  
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
        
    % amats
    for kk=1:numel(sys(i_sys).amats)
      sys(i_sys).amats{kk} = simplifyMatrix(sys(i_sys).amats{kk});
    end
    
    % bmats
    for kk=1:numel(sys(i_sys).bmats)
      sys(i_sys).bmats{kk} = simplifyMatrix(sys(i_sys).bmats{kk});
    end
    
    % cmats
    for kk=1:numel(sys(i_sys).cmats)
      sys(i_sys).cmats{kk} = simplifyMatrix(sys(i_sys).cmats{kk});
    end
    
    % dmats
    for kk=1:numel(sys(i_sys).dmats)
      sys(i_sys).dmats{kk} = simplifyMatrix(sys(i_sys).dmats{kk});
    end    
    
    sys(i_sys).clearAllUnits;
    sys(i_sys).clearNumParams;
    
    % updating size fields
    sys(i_sys).addHistory(getInfo('None'), pl , ssm_invars(i_sys), sys(i_sys).hist );
  end
  
  if nargout == numel(sys)
    for ii = 1:numel(sys)
      varargout{ii} = sys(ii);
    end
  else
    varargout{1} = sys;
  end
end


function m = simplifyMatrix(m)
  try
    m = eval(m);
  end
  if ~isnumeric(m)
    m = char(m);
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
end

