% SUMJOIN sums time-series signals togther
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUMJOIN sums time-series signals togther. The start time of
%              each signal is taken in to account when summing. The signals
%              are zero-padded at non-overlapping times.
%
%         s1:   |. . + + | 0 0 0 0 0
%         s2:    0 0 | + + + + | 0 0
%         s3:    0 0 0 | + + + + . |
%
% CALL:        b = sumjoin(a1, a2, pl)
%
% EXAMPLES:
%
% a1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', 10, 'nsecs', 10, ...
%               't0', 100))
% a2 = ao(plist('tsfcn', 't', 'fs', 10, 'nsecs', 15, 't0', 150))
% b  = sumjoin(a1, a2);
% iplot(b, a1, a2);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sumjoin')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sumjoin(varargin)
  
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
  
  % loop over AOs to get maximum and minimum end time
  tEnd    = 0;
  tStart  = 1e20;
  fs      = bs(1).data.fs;
  inhists = [];
  for jj = 1:numel(bs)
    % Only get the data type we want
    if isa(bs(jj).data, 'tsdata')
      % check sample rate
      if bs(jj).data.fs ~= fs
        error('### All input time-series must have the same sample rate.');
      end
      % check sampling
      if ~bs(jj).data.evenly()
        error('### This method only works on regularly sampled time-series.');
      end
      % get start and stop time
      x1 = bs(jj).data.getX(1);
      ts = x1 + bs(jj).data.t0.double;
      te = bs(jj).data.nsecs + ts;
      if te > tEnd
        tEnd = te;
      end
      if ts < tStart
        tStart = ts;
      end
      % store input history
      inhists = [inhists bs(jj).hist];
    else
      error('### It is not a time-series', bs(jj).name);
    end
  end
  
  % clear errors
  bs.clearErrors;

  % Zero pad and sum each signal
  name = 'sumjoin(';
  yall = zeros(round((tEnd - tStart)*fs),1);
  for kk = 1:numel(bs)
    if isa(bs(kk).data, 'tsdata')
      
      name = sprintf('%s%s, ', name, ao_invars{kk});
      
      x1   = bs(kk).x(1)   + bs(kk).t0.double;
      xn   = bs(kk).x(end) + bs(kk).t0.double + 1/fs;
      post = zeros(round((tEnd - xn)*fs),1);
      pre  = zeros(round((x1 - tStart)*fs),1);
      y    = [pre; bs(kk).y; post];
      yall = yall + y;
    end
  end
  xall = linspace(0, (tEnd - tStart) -1/fs, (tEnd - tStart)*fs)';
  name = [name(1:end-2) ')'];
  
  % Fix up this AO
  out = bs(1);
  out.data.setXY(xall, yall);
  out.data.collapseX;
  out.name = name;
  out.data.setT0(time(tStart));
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

