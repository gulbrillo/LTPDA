% COMBINE combines multiple pest objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMBINE combines multiple pest objects.
%
% CALL:        pout = combine(p1, p2, ...);
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'combine')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = combine(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all PESTs and plists
  [ps, ps_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
 
  out = copy(ps(1), 1);
  for kk = 2:numel(ps)

    out.name   = [out.name '_' ps(kk).name];
    out.names  = [out.names ps(kk).names];
    out.y      = [out.y; ps(kk).y];
    
    % treat errors, putting inf where we have no error.
    if isempty(out.dy)
      ody = nan(size(out.y));
    else
      ody = out.dy;
    end
    
    if isempty(ps(kk).dy)
      ady = nan(size(ps(kk).y));
    else
      ady = ps(kk).dy;
    end
    
    out.dy     = [ody; ady];
    
    out.yunits = [out.yunits ps(kk).yunits];
    
    % make unique parameters
    [out.names, IA, ~] = unique(out.names, 'stable');
    out.y      = out.y(IA);
    if ~isempty(out.dy)
      out.dy     = out.dy(IA);
    end
    out.yunits = out.yunits(IA);
    
    out.models = [out.models ps(kk).models];
    
    out.pdf    = []; 
    out.cov    = []; 
    out.corr   = []; 
    out.chi2   = []; 
    out.dof    = []; 
    out.chain  = []; 
    
  end
  
  % add history
  out.addHistory(getInfo('None'), [], ps_invars, [ps.hist]);
  
  % set output
  varargout{1} = out;
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.converter, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl_default = buildplist()
  pl_default = plist.EMPTY_PLIST;
end

