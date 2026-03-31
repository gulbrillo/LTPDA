% NORMDIST computes the equivalent normal distribution for the data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: NORMDIST computes the equivalent normal distribution for the
%              data. The mean and standard deviation are computed from the
%              data. The method returns the normal distribution evaluated
%              at the bin centers.
%
% CALL:        b = normdist(a)
%              b = normdist(a, pl)
%
% INPUTS:      a  - input analysis object(s)
%              pl - a parameter list
%
% OUTPUTS:     b  - xydata type analysis object(s) containing the
%                   normal distribution pdf
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'normdist')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = normdist(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pli, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  pl = applyDefaults(getDefaultPlist('Number of bins'), pli);
  normalize = utils.prog.yes2true(find_core(pl, 'norm'));
  
  % start looping
  bs(numel(as),1) = ao();

  for jj=1:numel(bs)
    
    % compute histogram to get bin centers.
    h = hist(as(jj), pl);
    % compute mean and standard deviation from the data
    mu = mean(as(jj).y);
    sig = std(as(jj).y);    
    % Compute exponent
    e = ((h.x-mu)./sig).^2;
    % compute PDF
    y = (exp(-0.5.*e))./(sig*sqrt(2*pi));        
    % Introduce normalization
    if normalize
      yunits = (as(jj).data.yunits)^(-1);
    else
      nn = sum(y);
      nd = sum(h.y);
      y = y.*nd./nn;
      yunits = 'Count';
    end
    % construct new AO
    % make a new xydata object
    xy = xydata(h.x, y);
    xy.setXunits(as(jj).data.yunits);
    xy.setYunits(yunits);
    bs(jj) = ao(xy);
    bs(jj).procinfo = plist('mu', mu, 'sig', sig);
    % name for this object
    bs(jj).name = sprintf('normdist(%s)', ao_invars{jj});
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
  end
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'Number Of Bins'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plo = buildplist(set)
  switch lower(set)
    case 'number of bins'
      plo = plist();
      
      % N number of bins
      p = param({'N', ['The number of bins to compute the histogram on. <br>' ...
        'This defines the bin centers for the PDF.']}, {1, {10}, paramValue.OPTIONAL});
      plo.append(p);
      
      % normalized output
      p = param({'norm', ['Normalized output. If set to true, it will give the normal distrubution PDF. <br>' ...
        'Otherwise, it will give an output comparable to the ao/hist method']}, paramValue.TRUE_FALSE);       
      p.val.setValIndex(2);
      plo.append(p);
      
    otherwise
      error('### Unknown default plist for the set [%s]', set);
  end
end


