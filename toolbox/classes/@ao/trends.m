% TRENDS computes the trend statistics of the input time-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TRENDS computes the trend statistics of the input time-series.
%
% CALL:        b = trends(a, pl)
% 
% Inputs:
%           a - input time-series AOs
% Outputs:
%           b - an array of collection objects, one per input time-series AO.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'trends')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = trends(varargin)

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

  % Make copies or handles to inputs
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Extract necessary parameters
  seglen = pl.find('seglen');
  nsegs  = pl.find('nsegs');
  ranges = pl.find('ranges');
  
  if ~isempty(nsegs)
    spl = plist('N', nsegs);
  else
    spl = plist('time length', seglen);
  end
  
  plotinfo.resetStyles;
  tsaos = [];
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! The ao/trends method can only be computed on input time-series. Skipping AO %s', ao_invars{jj});
    else
      tsaos = [tsaos bs(jj)];
    end
  end
  
  % check ranges
  if ~iscell(ranges)
    ranges = {ranges};
  end
  
  if numel(ranges) > 1 && numel(ranges) ~= numel(tsaos)
    error('Specify one range per time-series AO, or one range for all AOs');
  end
    
  % Loop over input AOs
  plotinfo.resetStyles;
  for jj = 1:numel(tsaos)
    % capture input history
    inhist = bs(jj).hist;
    
    % split data
    segs = split(bs(jj), spl);
    
    % name
    name = tsaos(jj).name;
    
    % compute statistics
    statpl = plist('axis', 'xy');
    s_min = join(min(segs, statpl));
    s_min.setName(sprintf('%s_min', name));
    s_max = join(max(segs, statpl));
    s_max.setName(sprintf('%s_max', name));
    s_mu  = join(mean(segs, statpl));
    s_mu.setDx([]);
    s_mu.setName(sprintf('%s_mean', name));
    
    % straight line fit
    p = linfit(s_mu);
    s_trend = p.eval(plist('type', 'tsdata', 'xdata', s_mu, 'xfield', 'x'));
    s_trend.setName(sprintf('%s_trend', name));
    s_trend.setProcinfo(plist('fit', p));
    s_trend.setT0(s_mu.t0);
    
    % fix x values    
    s_min.setX(s_mu.x);
    s_max.setX(s_mu.x);
    
    % process ranges
    if numel(ranges) == 1
      range = ranges{1};
    elseif numel(ranges) > 1
      range = ranges{jj};
    else
      range = [-inf inf];
    end
    
    uflag = s_max.setY(2*double(s_max.y >= range(2)));
    lflag = s_min.setY(double(s_min.y <= range(1)));
    flag  = uflag+lflag;
    flag.setName(sprintf('%s_flag', name));
    flag.setProcinfo(plist('range', range));
    
    % colours
    pi = plotinfo;
    
    s_min.setPlotinfo(pi);
    s_min.setPlotMarker('.');
    s_max.setPlotinfo(pi);
    s_max.setPlotMarker('.');
    s_mu.setPlotinfo(pi);
    s_mu.setPlotMarker('.');
    s_trend.setPlotinfo(pi);
    s_trend.setPlotMarker('.');
    s_trend.setPlotLineStyle('--');
    flag.setPlotinfo(pi);
    flag.setPlotMarker('.');
    
    % output collection
    c(jj) = collection(s_min, s_max, s_mu, s_trend, flag);
    c(jj).setNames({'min', 'max', 'mean', 'trend', 'flag'});
    c(jj).setName(sprintf('%s stats', name));
    
    % Add history
    c(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, c);
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  pl = plist();

  % segment length
  p = param({'seglen', 'The length in seconds of segments over which to compute the statistics.'}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
  % nsegs
  p = param({'nsegs', 'Choose the number of segments to split the data into for computing the statistics. This will override the segment length [seglen] parameter.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
                  
  % ranges
  p = param({'ranges', 'Give numerical pairs which act as min/max ranges. Specify one per input time-series (as a cell-array), or a single range to apply to all.'}, paramValue.EMPTY_CELL);
  pl.append(p);
                  
end

% END
