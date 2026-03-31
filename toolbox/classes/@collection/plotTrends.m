% PLOTTRENDS plots the trend collections produced by ao/trends.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOTTRENDS plots the trend collections produced by ao/trends.
%
%
% CALL:               hfig = plotTrends(c1, c2, c3, ..., pl)
%              [hfig, hax] = plotTrends(cs, pl)
%         [hfig, hax, hli] = cs.plotTrends(pl)
%
% INPUTS:      cN   - input collection objects
%              cs   - input collection objects array
%              pl   - input parameter list
%
% OUTPUTS:     hfig - handles to figures
%              hax  - handles to axes
%              hli  - handles to lines
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'plotTrends')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plotTrends(varargin)
  
  import utils.const.*
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [cs, c_invars] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Find parameters values
  
  % prepare output arrays
  hfig = [];
  hax  = [];
  hli  = [];
  
  % Apply method to all collections
  for kk = 1:numel(cs)
    
    [kkhfig, kkah, kkli] = plotTrendCollection(cs(kk));
    
    hfig = [hfig kkhfig];
    hax  = [hax kkah];
    hli  = [hli kkli];
    
  end
  
  
  % Deal with outputs
  if nargout == 1
    varargout{1} = hfig;
  end
  if nargout == 2
    varargout{1} = hfig;
    varargout{2} = hax;
  end
  if nargout == 3
    varargout{1} = hfig;
    varargout{2} = hax;
    varargout{3} = hli;
  end
  
end


function [hfig, ah, li] = plotTrendCollection(t)
  
  
  hfig = figure;
  
  ah(1) = subplot('Position', [0.1 0.44 0.84 0.53]);
  ah(2) = subplot('Position', [0.1 0.12 0.84 0.25]);
  
  % extract data
  min   = getObjectAtIndex(t.search('min'), 1); % min
  max   = getObjectAtIndex(t.search('max'), 1); % max
  mu    = getObjectAtIndex(t.search('mean'), 1);
  flag  = getObjectAtIndex(t.search('flag'), 1);
  tr    = getObjectAtIndex(t.search('trend'), 1);
    
  % setup 'error' for area plot
  e = -[mu.y - min.y  max.y - mu.y];
  
  % select top axes
  axes(ah(1));
  hold on
  
  % plot mean with max/min shaded area
  errorH = shadedErrorBar(mu.x, mu.y, e, 'k', 1);
  li = errorH.mainLine;
  set(li, 'Color', mu.plotinfo.style.getMATLABColor);  
  set(get(get(li,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend  
  set(errorH.patch, 'FaceColor', mu.plotinfo.style.getMATLABColor);
  set(errorH.patch, 'DisplayName', 'min/max');

  % plot mean using plot to get all the axis labels etc
  mu.setPlotAxes(ah(1));
  mu.setShowsErrors(true);
  mu = mu.plot;
  li = [li mu.plotinfo.line];
  
  % plot the linear trend
  tr.setPlotAxes(ah(1));
  tr.setPlotLineStyle(':');
  tr.setPlotMarker('none');  
  tr = plot(tr);
  li = [li tr.plotinfo.line];
  
  % add text patch with the fit values
  p = tr.procinfo.find('fit');  
  txt = {};
  for ll = 1:numel(p.y)
    txt = [txt {utils.plottools.fixAxisLabel(sprintf('P%d: %s %s', ll, p.y(ll), char(p.yunits(ll))))}];
  end
    
  Ylim = get(ah(1), 'YLim');  
  X    = tr.x(1);
  Y    = tr.y(1);
  
  axes(ah(1));
  ht = text(X, Y, txt);
  set(ht, 'fontsize', 16);
  set(ht, 'BackgroundColor',[0.97 0.97 0.97]);
  set(ht, 'EdgeColor', 'k');
  set(ht, 'Margin', 4);
  
  pos = get(ht, 'position');  
  pos(2) = Ylim(2) - 1.1*pos(2);  
  set(ht, 'position', pos);
    
  % plot limit lines
  range = flag.procinfo.find('range');
  ul = line([min.x(1) min.x(end)], [range(2) range(2)]);
  set(ul, 'linestyle', '--', 'linewidth', 3);
  ll = line([min.x(1) min.x(end)], [range(1) range(1)]);
  set(ll, 'linestyle', '--', 'linewidth', 3);
  box on;
  grid on;
  
  % plot flag on bottom axes
  axes(ah(2));
  flag.setPlotAxes(ah(2));
  flag.setPlotLinewidth(3);
  flag = plot(flag, plist('fcn', 'stairs'));  
  li = [li flag.plotinfo.line];
  set(ah(1), 'Xlim', get(ah(2), 'Xlim'))
  modes = {'OK', 'Underflow', 'Overflow', 'Both'};
  set(ah(2), 'YTick', 0:numel(modes)-1, 'YTickLabel', modes)
  legend(ah(2), 'hide');
  ylabel(ah(2), 'Flag');
  xlabel(ah(1), '');
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
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
  
end


% END
