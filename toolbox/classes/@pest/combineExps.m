% combineExps combine the results of different parameter estimation
% experimets and give the final joint estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: combineExps combine different parameter estimates into a
%              single joint estimate. Joint covariance is also computed.
%
% CALL:        obj = combineExps(objs);
%              obj = combineExps(objs);
%
% INPUTS:      obj - can be a vector
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'combineExps')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = combineExps(varargin)

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
  [pests, pest_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
 
  
  % combine plists
%   pl = parse(pl, getDefaultPlist());
  
  if nargout == 0
    error('### combineExps cannot be used as a modifier. Please give an output variable.');
  end
  
  if ~all(isa(pests, 'pest'))
    error('### combineExps must be only applied to pest objects.');
  end
  
  N = numel(pests);
  
  I = cell(N,1);
  C = cell(N,1);
  p = cell(N,1);
  pnames = cell(N,1);
  chi2 = zeros(N,1);
  dof = zeros(N,1);
  
  % Iterate over all input pest
  for ii=1:N
    
    counter =  sprintf('%u',ii);
    
    % Extract values
    pnames{ii} = pests(ii).names;
    p{ii} = pests(ii).y;
    chi2(ii) = pests(ii).chi2;
    if isempty(chi2(ii))
      error(['### Could not find chi2 value for input pest #' counter]);
    end
    dof(ii) = pests(ii).dof;
    if isempty(dof(ii))
      error(['### Could not find dof value for input pest #' counter]);
    end
    I{ii} = pests(ii).procinfo.find('infomatrix');
    C{ii} = pests(ii).cov;
    if isempty(C{ii})
      C{ii} = inv(I{ii});
    elseif isempty(I{ii})
      I{ii} = inv(C{ii});
    elseif isempty(I{ii}) && isempty(C{ii});
      error(['### Could not find covariance matrix for input pest #' counter]);
    end
    
  end
  
  % Now redefine all quantities to handle the general case when we have
  % different sizes
  Inew = cell(N,1);
  pnew = cell(N,1);
  pnamesAll = pnames{1};
  dofnew = zeros(N,1);
  chi2new = zeros(N,1);
  for ii=1:N
    pnamesAll = union(pnamesAll,pnames{ii});
  end
  Np = numel(pnamesAll);
  for ii=1:N
    Inew{ii} = zeros(Np);
    pnew{ii} = zeros(Np,1);
%     dofnew{ii} = zeros(Np,1);
    % information matrix
    for kk=1:Np
      for ll=1:Np
        ixk = strcmp(pnamesAll{kk},pnames{ii});
        ixl = strcmp(pnamesAll{ll},pnames{ii});
        ixk = find(ixk);
        ixl = find(ixl);
        if ixk~=0 & ixl~=0
          Inew{ii}(kk,ll) = I{ii}(ixk,ixl);
        end
      end
    end
    % param vector
    for kk=1:Np
      ix = strcmp(pnamesAll{kk},pnames{ii});
      ix = find(ix);
      if ix~=0
        pnew{ii}(kk) = p{ii}(ix);
      end
    end
    % dof & chi2
    dofnew(ii) = dof(ii) + numel(p{ii}) - Np;
    chi2new(ii) = chi2(ii) * dof(ii) / dofnew(ii);
    
%     for kk=1:Np
%       ix = strcmp(pnamesAll,pnames{ii}{kk});
%       ix = find(ix);
%       arr = I{ii}(kk,:);
% %       (1:kk) = arr(1:ix)
% %       Inew{ii}(ix,:) = [0 arr(kk:end)];
% %       pnew{ii}(kk) = p{ii}(ix);
%     end
  end
  I = Inew;
  p = pnew;
  dof = dofnew;
  chi2 = chi2new;
  
  % Compute joint information matrix
  II = zeros(size(I{1}));
  for ii=1:N
    II = II+I{ii};
  end
%   CC = inv(II);
  
  % Compute joint parameter estimate
  pp = zeros(size(p{1}));
  for ii=1:N
    pp = pp+I{ii}*p{ii};
  end
  pp = II\pp;
  
  % Compute joint errors and correlation matrix
  CC = inv(II);
  dp = sqrt(diag(CC));
  corr = zeros(size(CC));
  for ll=1:size(CC,1)
    for mm=1:size(CC,2);
      corr(ll,mm) = CC(ll,mm)/dp(ll)/dp(mm);
    end
  end
  
  % Compute joint chi2 and dof
  DOF = sum(dof);
  CHI2 = chi2'*dof/DOF;
  
  % Output pest
  out = pest();
  out = out.setNames(pnamesAll);
%   out = out.setYunits(pests(1).yunits);
  out = out.setY(pp);
  out = out.setCov(CC);
  out = out.setDy(dp);
  out = out.setCorr(corr);
  out = out.setChi2(CHI2);
  out = out.setDof(DOF);
  name = pests(1).name;
  if N>1
    for ii=2:N
      name = [name ',' pests(ii).name];
    end
  end
  out = out.setName(['combineExps(' name ')']);
  
  out.procinfo = plist('infomatrix',II);
  out.addHistory(getInfo('None'), pl, pest_invars(:), [pests(:).hist]);
     
  % Set outputs
  if nargout > 0
    varargout{1} = out;
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

function plo = buildplist()
  plo = plist.EMPTY_PLIST;
end

