% SETTLINGTIME retunrns 1% the settling time of the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETTLINGTIME retunrns 1% the settling time of the system.
%              It is a worst scenario assumption were all variable are
%              used.
%
% CALL: time = modifyTimeStep(sys,options)
%
% INPUTS:
%           sys - (array of) ssm objects
%       options - A plist or numeric value giving new timestep value (param name 'newtimestep')
%
% OUTPUTS:
%           sys - (array of) ssm
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'settlingTime')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = settlingTime(varargin)
  %% starting initial checks
  
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
  sys = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  %% begin function body
  if ~ numel(sys)==1
    error('settlingTime take only one input ssm object')
  end
  
  %% building output depending on options
  if ~sys.isnumerical
    error(['error in settlingTime because system "',sys.name, '" should be numerical to find settling time' ]);
  end
  % retriveing system infos
  Ts = sys.timestep;
  if Ts == 0
    sys.modifyTimeStep(0.001)
    Ts = 0.001;
  end
  A = double(sys);
  % initializing calculus
  tSettling = Ts;
  k=1;
  Xini = ones(size(A,2), 1);
  if numel(Xini)>0
    % iteration to observe decay
    while   max(abs(Xini)>0.01) && Ts<1e10
      k = k+1;
      tSettling = tSettling + Ts;
      Xini = A*Xini;
      % multiply timeStep by 2 after 20 iterations
      if k==20
        k=1;
        A = A*A;
        Ts = 2*Ts;
      end
    end
  else
    tSettling = 0;
  end
  varargout{1} = plist('settling_time', tSettling);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'discretize', 'The timestep used for a time-discrete system'}, 0.001 );
  pl.append(p);
end
