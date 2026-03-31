% DETECTOUTLIERS locates outliers in data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DETECTOUTLIERS locates outliers in ao objects.
%
%
% CALL:        out = obj.detectOutliers(pl)
%              out = detectOutliers(objs, pl)
%
% INPUTS:      pl      - parameter list containing detection threshold
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - timeseries aos (one per input ao) corresponding to a
% flag for detected outliers (1 for outlier, 0 for normal data)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'detectOutliers')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = detectOutliers(varargin)

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

% Apply defaults to plist
pl = applyDefaults(getDefaultPlist(), pls);

% Extract input parameters from the plist

% Threshold
thresh= pl.find('Threshold');
switch class(thresh)
  case 'ao'
    thresh = thresh.data.y;
  case 'double'
    % do nothing
  otherwise
    error('Threshold must either be a double or cdata ao');
end

% Check that we just have a scalar
if numel(thresh) ~= 1
  error('Only one threshold value can be passed');
end

% Cushion
cush = pl.find('Cushion');
switch class(cush)
  case 'ao'
    cush = cush.data.y;
  case 'double'
    % do nothing
  otherwise
    error('Cushion must either be a double or cdata ao');
end

% Did we get symmetric or asymmetric cushions?
switch numel(cush)
  % empty, assume no cushion
  case 0
    cush = [0,0];
    % single value, symmetric
  case 1
    cush = cush*[1,1];
    % two values, asymmetric
  case 2
    % don't need to do anything
  otherwise
    error('Cushion must be specified as single value (symmetric) or two values (pre- and post-trigger)');
end


% Loop over input objects
for jj = 1 : numel(objsCopy)
  % Process object jj
  object = objsCopy(jj);
  
  % Skip 3-D data
  if isa(object.data,'data3D')
    warning('Ignoring input object [%s] - contains 3D data',object.name);
    continue
  end
  
  % find median absolute deviation
  MAD = median(abs(object-median(object)));
  
  % some cases are pathological because they have a lot of zeros.  First
  %try standard deviation
  if MAD == 0
    MAD = std(object);
  end
  
  % if that doesn't work, just use 1
  if MAD == 0
    MAD.setY(1);
  end
  
  % make normalized data
  % NOTE: for Gaussian distribution, sigma ~ 1.48 MAD
  objnorm = (object-median(object))./MAD;
  
  % locate points above threshold
  idx = find(objnorm,plist('query',sprintf('abs(y)>%f',thresh),'mode','indices'));
  
  if ~isempty(idx) && idx.y(1) ~= 0
    % handle special case of single outlier
    if length(idx.y) == 1
      lhs_idx = idx.y;
      rhs_idx = idx.y;
    % general case of multiple outliers  
    else
      % want to find edges so we difference the index vector
      didx = idx.diff(plist('method','diff'));
      
      % right-hand side of gaps is the point where the diff is >1
      rhs = didx.find(plist('query','y>1','mode','indices'));
      
      % recover the original indices
      rhs_idx = idx.select(rhs.y);
      
      % add the last index
      rhs_idx = join(rhs_idx,ao(cdata(idx.y(end))));
      
      % widen the gap a bit to the right
      rhs_idx = rhs_idx+cush(2);
      
      % make sure all inidices lie within the data
      % NOTE: ao/min doesn't work like double/min for two input arguments so we
      % have to use this kludge.
      rhs_idx.setY(min(rhs_idx.y,numel(object.y)));
      
      % the left-hand indices are the ones just *after* the diff >1
      lhs_idx = idx.select(rhs.y+1);
      
      % need to add the first kick at the front
      lhs_idx = join(ao(cdata(idx.y(1))),lhs_idx);
      
      % widen the gap a bit to the left
      lhs_idx = lhs_idx-cush(1);
      
      % make sure all the indices lie within the data
      % NOTE: ao/max doesn't work like double/max for two input arguments so we
      % have to use this kludge.
      lhs_idx.setY(max(lhs_idx.y,1));
    end
    % create gap vector
    out(jj) = ao(plist(...
      'built-in','pulsetrain',...
      'rising',lhs_idx,...
      'falling',rhs_idx,...
      'fs',object.fs,...
      'nsecs',object.nsecs,...
      'T0',object.t0,...
      'TOFFSET',object.toffset,...
      'xunits',object.xunits,...
      'name',sprintf('detectOutliers(%s)',object.name)));
    
    % no outliers found
    pinfo = plist('indices',[double(lhs_idx)'; double(rhs_idx)']');
  else
    
    % create timeseries of zeros
    out(jj) = ao.zeros(object.nsecs,object.fs);
    out(jj).setT0(object.t0);
    out(jj).setToffset(object.toffset);
    out(jj).setXunits(object.xunits);
    out(jj).setName(sprintf('detectOutliers(%s)',object.name));
    
    pinfo = plist('indices',[]);
    
  end
  
  % Add history
  if ~callerIsMethod
    out(jj).addHistory(getInfo('None'), pl, obj_invars(jj), object.hist);
    out(jj).setProcinfo(pinfo);
  end
  
end % loop over analysis objects

% Set output
varargout = utils.helper.setoutputs(nargout, out);
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
  'Default' ...
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

% Threshold
p = param(...
  {'Threshold', ['Trigger threshold for detecting outliers. For Gaussian white noise with infrequent outliers, the units correspond to standard deviations.']},...
  10 ...
  );
pl.append(p);

% cushion
p = param(...
  {'Cushion', ['Number of data points to include before outlier trigger start and after outlier trigger end. Effectively widens triggered area.'...
  ' Can either specify a single value or a 2-element array corresponding to pre- and post-trigger cushion.']},...
  paramValue.EMPTY_DOUBLE ...
  );
pl.append(p);


% go through parameter sets
switch lower(set)
  % Default is Constant value(s)
  case 'default'
    
    % otherwise
  otherwise
    error('Unsuported set [%s]',set);
end
end
