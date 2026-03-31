% Stack xydata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Given an array of xydata with the same x vals, stack returns
%              a new xydata object with the same xvals and summed yvals.
%
% CALL:        b = stack(a1, a2, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'stack')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = stack(varargin)
  
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Copy inputs
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  inhists = [];
  for jj = 1:numel(bs)
    % Make sure all objects are xydata.
    if isa(bs(jj).data, 'xydata')      
      if numel(bs(1).x) ~= numel(bs(jj).x)
        error('### The number of xvals need to be the same for all objects.');
      end      
      if sum(bs(1).x - bs(jj).x) ~= 0
        error('### The xvals need to be the same for all objects.');
      end      
      % store input history
      inhists = [inhists bs(jj).hist];
    else
      error('### All objects need to be xydata.', bs(jj).name);
    end
  end
  
  % clear errors
  bs.clearErrors;

  % Zero pad and sum each signal
  name = 'stack(';
  xall = bs(1).x;
  yall = bs(1).y;
  tStart = bs(1).timespan.startT;
  tEnd   = bs(1).timespan.endT;
  for kk = 2:numel(bs)
    if isa(bs(kk).data, 'xydata')      
      name = sprintf('%s%s, ', name, ao_invars{kk});
      tStart = [tStart bs(kk).timespan.startT];
      tEnd   = [tEnd bs(kk).timespan.endT];
      yall = yall + bs(kk).y;      
    end
  end
  
  % Names can get too long so truncate if necessary.
  if numel(name) > 100
    name = [name(1:100) ' ...)'];
  else
    name = [name(1:end-2) ')'];
  end
  
  % Fix up this AO
  out = bs(1);
  out.data.setXY(xall, yall);
  out.setTimespan(timespan(min(tStart), max(tEnd)));
  out.name = name;
  out.hist = [];
  out.addHistory(getInfo('None'), pl, ao_invars, inhists);
  
  % Set output
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
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

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

