% computes Probability Density Function from a pest object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  computes Probability Density Function from a pest object.
%
% CALL:         p = computePdf(p,pl)
%               p.computePdf(pl)
%
% INPUTS:       p   -  pest object
%               pl  -  parameter list (BurnIn,nbins)
%
% OUTPUTs:      p   -  pest object with the computed normilized pdf
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'computePdf')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = computePdf(varargin)
  
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
  
  % Decide on a deep copy or a modify
  p = copy(pests, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  BurnIn = find_core(pl, 'BurnIn');
  nbins  = find_core(pl, 'nbins');
  
  if ~all(isa(pests, 'pest'))
    error('### computePdf must be only applied to pest objects.');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  N = numel(p);
  
  for ii=1:N
    a                  = p(ii).chain(:,4:size(p(ii).chain,2));
    D                  = size(a);
    [n(1,:),xout(1,:)] = hist(a(BurnIn:D(1),1),nbins);
    sumbins            = sum(n(1,:));
    PDF                = [xout(1,:) ; n(1,:)/sumbins]';
    
    for jj=2:D(2)
      % creating histograms
      [n(jj,:),xout(jj,:)] = hist(a(BurnIn:D(1),jj),nbins);
      sumbins              = sum(n(jj,:));
      PDF                  = [PDF xout(jj,:)' (n(jj,:)')/sumbins];
    end
    PDFn(:,:,ii)          = PDF;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Output pest/pdf
  if nargout == 1
    for ii = 1:N
      p(ii).setPdf(PDFn(:,:,ii));
    end
  elseif nargout == 0
    for ii = 1:N
      p(ii).setPdf(PDFn(:,:,ii));
    end
  else
    error('### The number of output arguments must be a one or zero');
  end
  
  p.addHistory(getInfo('None'), pl, pest_invars(:), [pests(:).hist]);
  
  name = p(1).name;
  if N>1
    for ii=2:N
      name = [name ',' p(ii).name];
    end
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = p;
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
  
  p = param({'BurnIn','Number of samples (of the chains) to be discarded'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'nbins','Number of bins of the pdf histogram computed for every parameter'}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
end

