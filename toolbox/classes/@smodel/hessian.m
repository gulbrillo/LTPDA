% hessian compute the hessian matrix for a symbolic model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: hessian compute the hessian matrix for a symbolic model.
%
% CALL:        H = hessian(obj);
%
% INPUTS:      obj - a smodel
%
% <a href="matlab:web(smodel.getInfo('hessian').tohtml, '-helpbrowser')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = hessian(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [mdl, mdl_invars] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
 
  
  if nargout == 0
    error('### hessian cannot be used as a modifier. Please give an output variable.');
  end
  
  if ~all(isa(mdl, 'smodel'))
    error('### hessian must be only applied to smodel objects.');
  end
  
  % Extract necessary parameters
  p = pl.find_core('params');
  
  if isempty(p) || strcmp(p,'all')
    p = mdl.params;
  end
  Np = numel(p);
%   grad = zeros(Np,1);
%   H = zeros(Np);
  
  % compute symbolic 1st-order differentiation
  for ll=1:Np
    grad(ll,1) = diff(mdl,p{ll});
  end
  
  % compute symbolic 2nd-order differentiation
  for mm=1:Np
    for ll=1:mm
      H(ll,mm) = diff(grad(ll),p{mm});
    end
  end
  
  % symmetrize matrix
  for ll=1:Np
    for mm=1:ll
      H(ll,mm) = H(mm,ll);
    end
  end
  
  % set name
  for ll=1:Np
    for m=1:Np
      H(ll,mm).name = sprintf('hessian(%s)', mdl.name);
    end
  end

  H.addHistory(getInfo('None'), pl, mdl_invars(:), [mdl(:).hist]);
       
  % Set outputs
  if nargout > 0
    varargout{1} = H;
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
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()

  pl = plist();
  
  % params to diff
  p = param({'params', 'A cell-array of parameters to differentiate with respect to.'}, 'all');
  pl.append(p);
  
end

