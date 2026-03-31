% RESAMPLETOCOMMONGRID Resamples Analysis Objects to a common grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Resamples Analysis Objects to a common grid
%
% CALL:        as = resampleToCommonGrid(a1,a2,a3,...)
%              as = resampleToCommonGrid(as)
%              as = as.resampleToCommonGrid()
%
% INPUTS:      aN   - input analysis objects (tsdata)
%              as   - input analysis objects array (tsdata)
%
% OUTPUTS:     as  - a vector of timespan object, of which:
%                     The start time is the earliest one
%                     % The end time is the latest one
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'resampleToCommonGrid')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = resampleToCommonGrid(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  if ~callerIsMethod
    % Collect all AOs
    [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    tsao = [];
    tsao_invars = {};
    for ll = 1:numel(as)
      if isa(as(ll).data, 'tsdata')
        tsao        = [tsao as(ll)];
        tsao_invars = [tsao_invars ao_invars(ll)];
      else
        warning('### getGeneralInterval requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t account for this AO', ao_invars{ll});
      end
    end
    inhists = [tsao(:).hist];
  else
    
    % Assume the input is a vector of timeseries AOs
    tsao = varargin{1};
  end
  
  % Aim to building a grid which the highest possible rate
  targetFs = pl.find('fsout', max(tsao.fs));
  ts_general = getGeneralInterval(tsao);
  
  gen_start = ts_general.startT;
  gen_stop  = ts_general.endT;
  ref_start = ts_general.procinfo.find('Reference');
  
  utils.helper.msg(msg.IMPORTANT, 'Resampling to common grid between %s and %s...', char(gen_start), char(gen_stop));
  
  % get a common grid from the earliest to the latest
  nsecs = double(gen_stop) - double(gen_start) + 1/targetFs;
  
  t = tsdata.createTimeVector(targetFs, nsecs);
  t = [t; t(end) + 1/targetFs];
  
  % Align the grid so it lays with the reference (more frequent) one
  dN = round((double(ref_start) - double(gen_start)) * targetFs);
  t = t - dN/targetFs;
  
  for kk = 1:numel(tsao)
    % set the same reference time
    tsao(kk).setReferenceTime(ref_start);
    
    % select the fraction of the grid suitable for the current object
    ts = tsao(kk).x;
    if numel(ts) <= 1
      warning('Can not interpolate [%s] onto common grid since it has too few samples.', tsao(kk).name);
      continue;
    end
    
    tsmin = ts(1);
    tsmax = ts(end);
    
    tt = t(t >= tsmin - 1/targetFs & t <= tsmax + 1/targetFs);
    nsecs = tt(end) - tt(1) + 1/targetFs;
    % create a formula for the vertices (assuming they are regularly
    % sampled)
    if ~isequal(tt, ts)
      
      % Interpolate only when needed
      tstr =  sprintf('%.17g + tsdata.createTimeVector(%.17f, %.17f)', tt(1), targetFs, nsecs);
      tsao(kk) = interp(tsao(kk), plist('vertices', tstr));
      
      % Ensure we really set the sample rate. There are internal rules
      % which check if the sample rate is significantly diffent, and so
      % it may not get set.
      tsao(kk).setFs(targetFs*2);
      tsao(kk).setFs(targetFs);
    end
  end
  
  % set to the same t0, clearing the toffset
  % - this seems to be necessary otherwise the split by timespan which
  % would follow if "should truncate" fails to do the right job. This
  % hints at a problem in split by timespan.
  refTime = pl.find('reference time');
  if ischar(refTime)
    switch lower(refTime)
      case 'original'
        refTime = [];
      case 'latest'
        [~, idx] = max(double(tsao.t0));
        refTime = tsao(idx).t0;
      case 'earliest'
        [~, idx] = min(double(tsao.t0));
        refTime = tsao(idx).t0;
      case 'first'
        refTime = tsao(1).t0;
    end
  end
  
  if ~isempty(refTime)
    tsao.setReferenceTime(refTime);
  end
  
  if pl.find('should truncate')
    ts_com = getCommonInterval(tsao);
    if ts_com.nsecs == 0
      warning('Could not find a common interval for this data set. Splitting will produce empty results!');
    end
    tsao = split(tsao, plist('timespan', ts_com));
    if any(diff(tsao.len))
      % In some obscure cases the objects could not the same length.
      % Make sure that they have the same length.
      minLen = min(tsao.len);
      tsao = split(tsao, plist('samples', [1 minLen]));
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, tsao);
  
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
  ii.setModifier(false);
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

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = buildplist()
  pl = plist();
  
  % Fs
  p = param({'fsout', 'The target sampling frequency.'}, {1, {[]}, paramValue.OPTIONAL});
  p.addAlternativeKey('fs');
  pl.append(p);
  
  % Reference time
  p = param({'Reference time', ['Set the reference time (t0). Either give a time, or specify ''original'', ''first'', ''latest'', or ''earliest''.<br>' ...
    'If nothing is specified, the start time of the investigation will be used.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Should truncate
  p = param({'should truncate', 'Decide if truncating or not the data after resampling'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end
