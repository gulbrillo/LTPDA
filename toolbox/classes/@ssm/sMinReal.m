% SMINREAL gives a minimal realization of a ssm object by deleting unreached states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SMINREAL gives a minimal realization of a ssm object by
%              deleting unreached states (! this is not always the minimal realization)
%
% CALL:        >> sys = sMinReal(sys);
%
%            sys - an array of ssm object
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'sMinReal')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sMinReal(varargin)
  
  %% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% send starting message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  %% collecting input
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [sys, ssm_invars] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  pl_user = plist;
  
  internal = utils.helper.callerIsMethod();
  
  sys = copy(sys, nargout);
  
  %% begin function body
  for i_sys=1:numel(sys)
    if ~sys(i_sys).isnumerical
      error('system should be numeric')
    end
    [A, B, C] = double(sys(i_sys), plist);
    x_control = isreached(A,B);
    x_sensing = isreached(A.',C.');
    x = logical(min(x_control, x_sensing));
    positions = ssm.blockMatRecut(x,sys(i_sys).sssizes, 1);
    
    options = plist('inputs','ALL','outputs','ALL', 'states', positions);
    sys(i_sys).doSimplify(options);
    if ~internal
      % append history step
      sys(i_sys).addHistory(getInfo('None'), pl_user, ssm_invars(i_sys), sys(i_sys).hist);
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

function x  = isreached(A,B)
  Alog = double(~(A==0));
  Blog = double(~(B==0));
  Nss = size(B,1);
  Nin = size(B,2);
  x = zeros(Nss, 1);
  for i =0:Nss
    Ai = Alog^i;
    for j=1:Nin
      xloc = Ai*Blog(:,j);
      xloc = double(~(xloc==0));
      x = max(x, xloc);
    end
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
function plo = getDefaultPlist()
  plo = plist;
end

