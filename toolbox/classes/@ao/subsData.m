% SUBSDATA performs actions on ao objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBSDATA performs actions on <class> objects.
%
%
% CALL:        out = obj.subsData(pl)
%              out = subsData(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - some output.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'subsData')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = subsData(varargin)

% Determine if the caller is a method or a user
callerIsMethod = utils.helper.callerIsMethod;

% Check if this is a call for parameters
if utils.helper.isinfocall(varargin{:})
  varargout{1} = getInfo(varargin{3});
  return
end

% Print a run-time message
import utils.const.*
utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

% Collect input variable names for storing in the history
in_names = cell(size(varargin));
try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

% Collect all objects of class ao
[objs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
[pls, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

%--- Decide on a deep copy or a modify.
% If the no output arguments are specified, then we are modifying the
% input objects. If output arguments are specified (nargout>0) then we
% make a deep copy of the input objects and return modified versions of
% those copies.
objsCopy = copy(objs, nargout);

% determine the set of keys we are using: the set is just the specified
% mode, or Default
pl_in = combine(pls);
mode = pl_in.find('mode');
if isempty(mode) || strcmpi(mode, 'constant')
  set = 'default';
else
  set = mode;
end

% Apply defaults to plist
pl = applyDefaults(getDefaultPlist(set), varargin{:});

% Extract input parameters from the plist

% Index
idx = pl.find('indices');
sflag = pl.find('sub_flag');


% figure out what the user gave us. Note that if we got a gap vector, we
% need to handle it on a per object basis to get the times to line up

% user forgot to pass anything
if isempty(idx) && isempty(sflag)
  error('either subsitution indicies or subsitution flag must be specified');
  
  % user passed indices
elseif ~isempty(idx) && isempty(sflag)
  % check class and extract from AO if necessary
  switch class(idx)
    case 'ao'
      idx = idx.data.y;
    case 'double'
      % do nothing
    otherwise
      error('start/stop data must be double array or cdata ao');
  end
  
  
  % check that index is Nx2
  if (size(idx,2)~=2)
    error('Start/stop index array must be Nx2');
  end
  
  % user passed both by mistake
elseif ~isempty(idx) && ~isempty(sflag)
  error('subsitution indices and subsitution flag can not simultaneously be passed to subsData');
end


% deal with negative indices (ignore or trim)
for ii = 1:size(idx,1)
  if idx(ii,1) < 1
    % entire index is negative, ignore
    if idx(ii,2) < 1
      warning('negative subsitution index found, ignoring')
      idx(ii,:) = [];
      % just the bottom half is negative, so trim to first sample
    else
      warning('negative substitution index found, trimming');
      idx(ii,1) = 1;
    end
  end
end

% Mode
subsMode = pl.find('mode');
switch lower(subsMode)
  % additional plist items for constant
  case 'constant'
    % Values
    subsValues = pl.find('value');
    % check class and extract from AO if necessary
    switch class(subsValues)
      case 'ao'
        subsValues = subsValues.y;
      case 'double'
        % do nothing
      otherwise
        error('subsitution values must be double array or ao');
    end
    % additional plist items for line
  case 'line'
    % additional plist items for polynomial
  case 'polynomial'
    order = pl.find('order');
    Nconst = pl.find('nconst');
    % additional plist items for spline
  case 'spline'
    Nconst = pl.find('nconst');
    % additional plist items for CG
  case 'constrained gaussian'
    % IACF
    Cinv = pl.find('IACF');
    % check class and extract from AO if necessary
    switch class(Cinv)
      case 'ao'
        Cinv = transpose(Cinv.y);
      case 'double'
        Cinv = reshape(Cinv,length(Cinv),1);
      otherwise
        error('IACF data must be double array or xydata ao');
    end
end


% Loop over input objects
for jj = 1 : numel(objsCopy)
  % Process object jj
  object = objsCopy(jj);
  
  % get indicies for the case where we passed substitution flag
  if isempty(idx) && ~isempty(sflag)
    sflag = sflag.resample(plist('fsout',object.fs));
    sflag = sflag.split(plist('match',object));
    idx = sflag.edgedetect();
    idx = idx.y;
    % deal with bug for idx == 0
    if numel(idx) == 1 && idx == 0
      idx = [];
    end
    % rotate for case where we only have one substitution point
    if size(idx,1) == 2 && size(idx,2) == 1
      idx = transpose(idx);
    end
  end
  
  % Skip 3-D data
  if isa(object.data,'data3D')
    warning('Ignoring input object [%s] - contains 3D data',object.name);
    continue
  end
  
  % Select Mode
  if ~isempty(idx)
    switch lower(subsMode)
      case 'constant'
        Nsubs = size(idx,1);
        % check that subsitution values are constant or length of indices
        if numel(subsValues) == 1
          subsValues = subsValues*ones(Nsubs,1);
        elseif numel(subsValues) == Nsubs
          % do nothing
        else
          error('Subsitution values must be a scalar or an array of same length as start/stop indices');
        end
        object.setY(replaceValuesWithConst(object.y,idx,subsValues));
      case 'mean'
        object.setY(replaceValuesWithMean(object.y,idx));
      case 'line'
        object.setY(replaceValuesWithLine(object.y,idx));
      case 'polynomial'
        object.setY(replaceValuesWithPoly(object.y,idx,order,Nconst));
      case 'spline'
        object.setY(replaceValuesWithSpline(object.y,idx,Nconst));
      case 'constrained gaussian'
        % Find Seed
        sd = pl.find('Seed');
        
        % initialize from clock if empty
        if isempty(sd), sd = sum(clock*100); end
        
        % set the seed to the plist so that it goes in the history.
        pl.pset('Seed', sd);
        
        % set seed (so long as we support 2010b, we need to do this)
        if verLessThan('MATLAB', '7.12')
          prevRandStream = RandStream.getDefaultStream;
          RandStream.setDefaultStream(RandStream('mt19937ar','seed', sd));
          oncleanup = onCleanup(@() RandStream.setDefaultStream(prevRandStream));
        else
          prevRandStream = RandStream.getGlobalStream;
          RandStream.setGlobalStream(RandStream('mt19937ar','seed', sd));
          oncleanup = onCleanup(@() RandStream.setGlobalStream(prevRandStream));
        end
        
        object.setY(replaceValuesWithCG(object.y,idx,Cinv));
        
        % put the seed used in the procinfo so that calling methods can (if
        % needed) reproduce this
        object.procinfo = plist('seed', sd);
        
      otherwise
        error('Unrecognized mode [%s]',subsMode);
    end
  end
  
  % set name
  object.setName(sprintf('subsData:%s(%s)', subsMode, object.name));
  
  
  % Add history
  if ~callerIsMethod
    object.addHistory(getInfo('None'), pl, obj_invars(jj), object.hist);
  end
end % loop over analysis objects

% Set output
varargout = utils.helper.setoutputs(nargout, objsCopy);
end

%--------------------------------------------------------------------------
% Subsitution Routine for Constant Values
%--------------------------------------------------------------------------
function y = replaceValuesWithConst(y,idx,subsValues)

% Loop through gaps and replace with constants
for ii = 1:size(idx,1)
  y(idx(ii,1):idx(ii,2))=subsValues(ii)*ones(idx(ii,2)-idx(ii,1)+1,1);
end

end

%--------------------------------------------------------------------------
% Subsitution Routine for Mean Value of Averages
%--------------------------------------------------------------------------
function y = replaceValuesWithMean(y,idx)

% Loop through gaps and replace with constants
for ii = 1:size(idx,1)
  ym = 0.5*(y(idx(ii,1)-1)+y(idx(ii,2)+1));
  y(idx(ii,1):idx(ii,2))=ym*ones(idx(ii,2)-idx(ii,1)+1,1);
end

end

%--------------------------------------------------------------------------
% Subsitution Routine for Straight Line
%--------------------------------------------------------------------------
function y = replaceValuesWithLine(y,idx)

% Loop through gaps and replace with constants
for ii = 1:size(idx,1)
  x = 0:(idx(ii,2)-idx(ii,1));
  % gap is entirely in the data
  if idx(ii,1) > 1 && idx(ii,2) < length(y)
    dy = y(idx(ii,2)+1)-y(idx(ii,1)-1);
    dx = length(x)+1;
    y(idx(ii,1):idx(ii,2))=y(idx(ii,1)-1)+dy/dx*(x+1);
    % gap starts at the beginning, start line at 0
  elseif idx(ii,1) <= 1
    dy = y(idx(ii,2)+1);
    dx = idx(ii,2)+1;
    y(idx(ii,1):idx(ii,2))=dy/dx*(x+1);
    % gap extends to the end, end line at 0
  elseif idx(ii,2) >= length(y)
    dy = -y(idx(ii,1)-1);
    dx = length(y)-(idx(ii,1)+1);
    y(idx(ii,1):idx(ii,2))=y(idx(ii,1)-1)+dy/dx*(x+1);
  else
  end
end

end

%--------------------------------------------------------------------------
% Subsitution Routine for Polynomial
%--------------------------------------------------------------------------
function y = replaceValuesWithPoly(y,idx,order,Nconst)

% make a gap-flag vector (ones for data, zeros for gaps)
flag = ones(size(y));
flag = replaceValuesWithConst(flag,idx,zeros(size(idx,1),1));

% Loop through gaps and replace with polynomial fit
for ii = 1:size(idx,1)
  
  % find constraining points
  start = max(idx(ii,1)-Nconst,1);
  stop = min(idx(ii,2)+Nconst,length(y));
  
  % fitting data
  yfit = y(start:stop);
  xfit = (0:length(yfit)-1)';
  flagfit = flag(start:stop);
  
  % throw out points where there are gaps
  goodIdx = find(flagfit);
  xgood = xfit(goodIdx);
  yfit = yfit(goodIdx);
  
  % make polynomial fit
  pfit = polyfit(xgood,yfit,order);
  
  % replace data in that index
  y(idx(ii,1):idx(ii,2))=polyval(pfit,xfit(idx(ii,1)-start:idx(ii,2)-start));
end

end

%--------------------------------------------------------------------------
% Subsitution Routine for Spline
%--------------------------------------------------------------------------
function y = replaceValuesWithSpline(y,idx,Nconst)

% make a gap-flag vector (ones for data, zeros for gaps)
flag = ones(size(y));
flag = replaceValuesWithConst(flag,idx,zeros(size(idx,1),1));

% Loop through gaps and replace with spline fit
for ii = 1:size(idx,1)
  
  % find constraining points
  start = max(idx(ii,1)-Nconst,1);
  stop = min(idx(ii,2)+Nconst,length(y));
  
  % fitting data
  yfit = y(start:stop);
  xfit = (0:length(yfit)-1)';
  flagfit = flag(start:stop);
  
  % throw out points where there are gaps
  goodIdx = find(flagfit);
  xgood = xfit(goodIdx);
  yfit = yfit(goodIdx);
  
  % make polynomial fit
  spfit = spline(xgood,yfit);
  
  % replace data in that index
  y(idx(ii,1):idx(ii,2))=ppval(spfit,xfit(idx(ii,1)-start:idx(ii,2)-start));
end

end

%--------------------------------------------------------------------------
% Subsitution Routine for Constrained Gaussian
%--------------------------------------------------------------------------
function yout = replaceValuesWithCG(yin,idx,Cinv)

% Want to remove a trend (mean or potentially linear) that is added back
% at the end. To avoid bias from data in the gaps, we only fit on the
% data outside the gaps.

z = ones(size(yin));
z = replaceValuesWithConst(z,idx,zeros(size(idx,1),1));
z = logical(z);
nn = (0:length(yin)-1)';
linterm = polyfit(nn(z),yin(z),0); % remove mean, could change to line, etc.
yin = yin-polyval(linterm,nn);

% now we make sure we have zeros in the gaps
yin = replaceValuesWithConst(yin,idx,zeros(size(idx,1),1));

% We add some extra large gaps of size M to either side of the
% timeseries so that we can properly coorelate with the true gaps at the
% edges of the  data. Is this the right size?

% 1/2 size of 2-pt function
M = floor(length(Cinv)/2);

% now just make sure that Cinv is of a compatible length to M.
Cinv = Cinv(1:2*M);

% change gap index vector
ngaps = size(idx,1);
idx_new = zeros(ngaps+2,2);
% gap of M at the beginning
idx_new(1,:) = [1 M];
% shift indices of exisitng gaps
idx_new(2:ngaps+1,1) = idx(:,1)+M;
idx_new(2:ngaps+1,2) = idx(:,2)+M;
% gap of M at the end
idx_new(ngaps+2,:) = length(yin)+M+[1 M];
% reset idx
clear idx
idx = idx_new;
clear idx_new

% zero-pad timeseries
yin = [zeros(M,1)' yin' zeros(M,1)']';

% maximum size of constraining points = max gap size + length(2pt)
tot_pts = max(idx(:,2)-idx(:,1))+1+2*M;

% generate lower-index covariance matrix from two-point function
cfilt = [fliplr(Cinv(2:end)) Cinv];

% for data points that are beyond the length of our two-point function,
% we simply extend the last point of the two point function. This could
% be replaced with a more sophisticated extrapolation, e.g. linear or
% power-law.
Cli_pad = Cinv(end)*ones(tot_pts,tot_pts+2*M);
for ii = 1:tot_pts
  Cli_pad(ii,ii:ii+4*M-2) = cfilt;
end

Cli = Cli_pad(:,2*M:end-2*M+1);


% Compute random part of gaps based on covariance alone, including
% covariance between gaps. Note that this part doesn't change between
% subsequent iterations with the same seed.

% generate inv covariance matrix for all gaps
Cli_all = iacf_all_gaps(Cli,idx);

% take inverse to get upper index
Cui_all = inv(Cli_all);

% random part for all gaps
randfill = MCMC.drawSample(zeros(1,size(Cui_all,1)),Cui_all);
%   randfill = mvnrnd(zeros(1,size(Cui_all,1)),Cui_all);

% Now we compute the deterministic piece based on the true data around
% the gaps

% first we have to zero-pad the timeseries again but this time we don't
% treat the padding as a new gap to fill.

% zero-pad timeseries
yin = [zeros(M,1)' yin' zeros(M,1)']';
% shift indicies
idx(:,1) = idx(:,1)+M;
idx(:,2) = idx(:,2)+M;

% copy input to output to initialize
yout = yin;

% loop over number of iterations
ngaps = size(idx,1);

% vector for all lambda terms
lam_all = [];
% loop through gaps
for ii = 1:ngaps
  
  % get constraining points
  yconst = yin(idx(ii,1)-M:idx(ii,2)+M);
  
  % number of constraining points
  nconst = length(yconst);
  
  % covariance matrix for constraining points
  Cli_const = Cli(1:nconst,1:nconst);
  
  % get lambdas
  lam = Cli_const*yconst;
  
  % pick out points in gap & add to lambda vector for all gaps
  lam_all = [lam_all; lam(M+1:end-M)];
  
end

% compute offsets for all gaps
delta = -Cui_all*lam_all;

% counter for running through randfill
gapStart = 1;

% loop through gaps and fill
for ii = 1:ngaps
  
  % get gap size
  gapSize = idx(ii,2)-idx(ii,1)+1;
  
  % determine stopping index
  gapStop = gapStart+gapSize-1;
  
  % fill gap
  yout(idx(ii,1):idx(ii,2)) = delta(gapStart:gapStop)+randfill(gapStart:gapStop)';
  
  % incrememnt to next gap
  gapStart = gapStart+gapSize;
end

% remove zero pads
yout(1:2*M) = [];
yout(end-2*M+1:end) = [];

% add back linear trend
yout = yout+polyval(linterm,nn);
end

%--------------------------------------------------------------------------
% sub-routine to generate covariance matrix over all gaps
%--------------------------------------------------------------------------
function covOut = iacf_all_gaps(Cli,gapIdx)

% total points in all the gaps
tot_pts = sum(gapIdx(:,2)-gapIdx(:,1))+size(gapIdx,1);

% 1/2 size of truncated covariance matrix
M = floor(size(Cli,1)/2);

% gap size & spacing
ngaps = size(gapIdx,1);  % number of gaps
gapSize = gapIdx(:,2)-gapIdx(:,1)+1; % size of gaps

% pad with constant to handle gaps that happen to fall on the edge of truncated 2-pt funciton
Cli_pad = Cli(1,end)*ones(size(Cli)+max(gapSize)*[1 1]);
Cli_pad(1:size(Cli,1),1:size(Cli,2)) = Cli;

% build large covariance matrix. The logic here is that we build it up as
% subblocks using the full 2Mx2M covariance matrix that we already had to
% compute. For points beyond the truncated 2pt function, we simply take
% the last point.
covOut = Cli(1,end)*ones(tot_pts);
kk = 1;
ll = 1;
for ii = 1:ngaps
  for jj = ii:ngaps
    offset = gapIdx(jj,1)-gapIdx(ii,1);
    if offset < 2*M
      colStart = 1+offset;
      colStop = colStart+gapSize(jj)-1;
      covOut(kk:kk+gapSize(ii)-1,ll:ll+gapSize(jj)-1) = Cli_pad(1:gapSize(ii),colStart:colStop);
      covOut(ll:ll+gapSize(jj)-1,kk:kk+gapSize(ii)-1) = Cli_pad(colStart:colStop,1:gapSize(ii));
    end
    ll = ll+gapSize(jj);
  end
  kk = kk+gapSize(ii);
  ll = kk;
end

end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
if nargin == 1 && strcmpi(varargin{1}, 'None')
  sets = {};
  pl   = [];
elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
  sets{1} = varargin{1};
  pl = getDefaultPlist(sets{1});
else
  sets = SETS();
  % get plists
  pl(size(sets)) = plist;
  for kk = 1:numel(sets)
    pl(kk) =  getDefaultPlist(sets{kk});
  end
end
% Build info object
ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
out = {...
  'Default', ...
  'Mean',    ...
  'Line',...
  'Constrained Gaussian'...
  };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(varargin)
persistent pl;
persistent lastset;

if nargin == 1, set = varargin{1}; else set = 'default'; end

if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
  pl = buildplist(set);
  lastset = set;
end
plout = pl;
end

function pl = buildplist(set)

% Create empty plsit
pl = plist();

% Indices
p = param(...
  {'Indices', ['List of start/stop index pairs for data to be subsituted'...
  ' (Nx2). Can either be an array of doubles or a cdata ao']},...
  paramValue.EMPTY_DOUBLE...
  );
pl.append(p);

% SUB_FLAG
p = param(...
  {'sub_flag', ['Timeseries AO containing ones where data should substituted '...
  ' and zeros where it should be kept. NOTE: This is an alternative to specifying Indices.']},...
  []...
  );
pl.append(p);


% Mode
p = param(...
  {'Mode',['Method to use for calculating replacement data.<ul>'...
  '<li>Constant - Replace with constant value</li>', ...
  '<li>Mean - Replace with average of interval edges</li>', ...
  '<li>Line - Replace with straight line between interval edges</li>', ...
  '<li>Polynomial - Replace with polynomial fit to neighboring data</li>',...
  '<li>Spline - Replace with cubic spline fit to neighboring data</li>',...
  '<li>Constrained Gaussian - Replace with random data obeying statistics specified in IACF</li></ul>']},...
  {1, {'Constant', 'Mean', 'Line', 'Constrained Gaussian'}, paramValue.SINGLE});
pl.append(p);

% go through parameter sets
switch lower(set)
  % Default is Constant value(s)
  case 'default'
    % Value
    p = param(...
      {'Value', ['Value(s) to fill specified intervals. Can be a scalar or Nx1 array of doubles or ao [where y values will be taken]']},...
      paramValue.DOUBLE_VALUE(0)...
      );
    p.addAlternativeKey('Values');
    pl.append(p);
    
    % Mean
  case 'mean'
    % no additional parameters needed.
    
    % Line
  case 'line'
    % no additional parameters needed.
    
    % Polynomial
  case 'polynomial'
    
    % Order
    p = param(...
      {'Order', ['Order of the polynomial interpolation']},...
      1 ...
      );
    pl.append(p);
    
    % NCONST
    p = param(...
      {'NCONST', ['Number of constraining points on either side of the interval used to make polynomial fit.']},...
      10 ...
      );
    pl.append(p);
    
    % Spline
  case 'spline'
    
    % NCONST
    p = param(...
      {'NCONST', ['Number of constraining points on either side of the interval used to make spline fit.']},...
      10 ...
      );
    pl.append(p);
    
    % Constrained Gaussian
  case 'constrained gaussian'
    
    % Seed
    p = param(...
      {'Seed', ['Set the set used to initialise the random number generator which generates the random data for the gaps.']},...
      paramValue.EMPTY_DOUBLE...
      );
    pl.append(p);
    
    % Inverse auto-correlation function
    p = param(...
      {'IACF', ['Inverse Auto-Correlation Function (IACF) for filling gaps. Can be array of doubles of xydata ao.']},...
      paramValue.EMPTY_DOUBLE...
      );
    pl.append(p);
    
    % otherwise
  otherwise
    error('Unsuported set [%s]',set);
end
end
