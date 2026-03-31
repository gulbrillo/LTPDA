% IPLOT provides an intelligent plotting tool for LTPDA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IPLOT provides an intelligent plotting tool for LTPDA.
%
% CALL:               hfig = iplot (a,pl)
%              [hfig, hax] = iplot (a,pl)
%         [hfig, hax, hli] = iplot (a,pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis object
%
% OUTPUTS:     hfig - handles to figures
%              hax  - handles to axes
%              hli  - handles to lines
%
% AO Plot Info
% ------------
%
%
% Notes on Parameters
% -------------------
%
%        Many of the properties take cell-array values. If the length of
%        the cell array is shorter than the number of lines to plot, the
%        remaining lines will be plotted with the default options. If the
%        cell array is of length 2 and the first cell contains the string
%        'all', then the second cell is used to set the propery of all
%        lines.
%
%
% Error parameters: If you give more than one input AO then you must
%                   specify the following parameter values in a cell-array,
%                   one cell for each input AO. Leave the cell empty to
%                   plot no errors. Each error can be a value or a vector
%                   the same length as the data vector. If you give and
%                   upper limit but not lower limit, then the errors are
%                   assumed to be symmetric (and vice versa)
%
%
% EXAMPLES:
%
% 1) Plot two time-series AOs with different colors, line styles, and widths
%
%   pl = plist('Linecolors', {'g', 'k'}, 'LineStyles', {'None', '--'}, 'LineWidths', {1, 4});
%   iplot(tsao1, tsao2, pl);
%
% 2) Plot two time-series AOs in subplots. Also override the second legend
%    text and the first line style.
%
%   pl = plist('Arrangement', 'subplots', 'LineStyles', {'--'}, 'Legends', {'', 'My Sine Wave'});
%   iplot(tsao1, tsao2, pl);
%
%
% 3) Plot two frequency-series AOs on subplots with the same Y-scales and
%    Y-ranges
%
%   pl1 = plist('Yscales', {'All', 'lin'});
%   pl2 = plist('arrangement', 'subplots', 'YRanges', {'All', [1e-6 100]});
%   iplot(fsd1, fsd2, pl1, pl2)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'iplot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DEPRECATED xmaths and ymaths in release 2.4

% 3) Plot two time-series AOs taking the square of the y-values of the
%    first AO and the log of the x-values of the second AO.
%
%   pl = plist('Arrangement', 'subplots', 'YMaths', 'y.^2', 'XMaths', {'', 'log(x)'});
%   iplot(tsao1, tsao2, pl);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TODO:
%    1) Add XRange, YRange, ZRange to xyzdata
%

function varargout = iplot(varargin)
  
  import utils.const.*
  
  %% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [upl, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  if numel(upl)>1, upl = combine(upl); end
  
  %% Go through AOs and collect them into similar types
  
  tsAOs  = [];
  fsAOs  = [];
  xyAOs  = [];
  xyzAOs = [];
  cAOs   = [];
  tfAOs  = [];
  
  consistent = 1;
  for jj = 1:numel(as)
    % Check if AOs are consistent (all containing data of the same class):
    if ~strcmpi(class(as(jj).data) , class(as(1).data) ), consistent = 0; end;
    switch class(as(jj).data)
      case 'tsdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          tsAOs = [tsAOs as(jj)]; %#ok<*AGROW>
        end
      case 'fsdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          fsAOs = [fsAOs as(jj)];
        end
      case 'xydata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          xyAOs = [xyAOs as(jj)];
        end
      case 'xyzdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name); %#ok<*WNTAG>
        else
          xyzAOs = [xyzAOs as(jj)];
        end
      case 'cdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          cAOs = [cAOs as(jj)];
        end
      case 'tfmap'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          tfAOs = [tfAOs as(jj)];
        end
      otherwise
        warning('!!! Unknown data type %s', class(as(jj).data));
    end
  end
  
  
  %% Now plot all the objects on separate figures
  %  (unless they're consistent and a figure handle was passed)
  
  if consistent && ~isempty(upl), fig2plot = find_core(upl,'Figure'); else fig2plot = []; end
  
  hfig = [];
  hax  = [];
  hli  = [];
  
  %----------- TSDATA
  if ~isempty(tsAOs)
    % get default plist
    dpl = getDefaultPlist('Time-series plot');
    % combine the plists
    pl = applyDefaults(dpl, upl);
    % Call x-y plot
    [hf, ha, hl] = xy_plot(tsAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  %----------- XYDATA
  if ~isempty(xyAOs)
    % get default plist
    dpl = getDefaultPlist('X-Y data plot');
    % combine the plists
    pl = parse(upl, dpl);
    % Call x-y plot
    [hf, ha, hl] = xy_plot(xyAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  %----------- XYZDATA
  if ~isempty(xyzAOs)
    % get default plist
    dpl = getDefaultPlist('3D plot');
    % combine the plists
    pl = applyDefaults(dpl, upl);
    % Call x-y-z plot
    [hf, ha, hl] = xyz_plot(xyzAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  %----------- CDATA
  if ~isempty(cAOs)
    % get default plist
    dpl = getDefaultPlist('Y data plot');
    % combine the plists
    pl = applyDefaults(dpl, upl);
    % Call x-y plot
    [hf, ha, hl] = y_plot(cAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  %----------- FSDATA
  if ~isempty(fsAOs)
    % get default plist
    dpl = getDefaultPlist('Frequency-series plot');
    % combine the plists
    pl = applyDefaults(dpl, upl);
    % Call fsdata plot
    [hf, ha, hl] = fs_plot(fsAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  %----------- TFMAP
  if ~isempty(tfAOs)
    % get default plist
    dpl = getDefaultPlist('Time-Frequency plot');
    % combine the plists
    pl = applyDefaults(dpl, upl);
    % Call fsdata plot
    [hf, ha, hl] = tf_plot(tfAOs, pl, fig2plot);
    hfig = [hfig hf];
    hax  = [hax ha];
    hli  = [hli hl];
  end
  
  % check some plot were effectively done
  if isempty(hfig)
    error('### No plots were produced. Maybe the input objects were empty?');
  end
  
  if isempty(hli)
    error('Failed to plot any data');
  end
  
  % put box on
  utils.plottools.box(hax, 'on');
  
  % add provenance to each figure
  if pl.find_core('show provenance')
    reqs = as.requirements(plist('hashes', true));
    for jj=1:numel(hfig)
      utils.plottools.addPlotProvenance(hfig(jj), reqs{:});
    end
  end
  
  % store input plist in each figure
  for kk=1:numel(hfig)
    utils.plottools.cacheObjectInUserData(hfig(kk), pl);
  end
  
  % set name for each figure
  names = pl.find_core('FigureNames');
  if isempty(names)
    names = getFigureNames(hfig);
  end % End if empty figure names
  
  names = cellstr(names);
  if numel(hfig) ~= numel(names)
    names = repmat(names, size(hfig));
  end
  
  for kk=1:numel(hfig)
    set(hfig(kk), 'Name', names{kk});
  end
  
  % select the data axes again
  for ff=1:numel(hfig)
    chs = get(hfig(ff), 'children');
    for kk=1:numel(chs)
      tag = get(chs(kk), 'tag');
      switch lower(tag)
        case 'legend'
          uistack(chs(kk), 'top');
        case 'ltpda_annotation'
        case 'colorbar'
        otherwise
          axes(chs(kk));
      end
    end
    
    % make draft
    utils.plottools.makeDraft(hfig, true);
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
  
  if nargout > 3
    error('### Incorrect number of outputs');
  end
  
end

function names = getFigureNames(hfig)
  names = {};
  try
    % try to get the title for each
    for ff=1:numel(hfig)
      title = '';
      ch = get(hfig(ff), 'Children');
      for cc = 1:numel(ch)
        if strcmp(get(ch(cc), 'type'), 'axes')
          tt = get(ch(cc), 'title');
          if ~ischar(tt)
            % assume it's a text object
            title = get(tt, 'String');
          else
            title = tt;
          end
        end
        
        if ~isempty(title)
          break;
        end
      end
      
      if isempty(title)
        % get the name of the first object plotted
        udata = get(hfig(ff), 'UserData');
        if iscell(udata) && numel(udata) > 1
          d = udata{1};
          if isa(d, 'ltpda_uoh')
            title = d.name;
          end
        end
      end
      
      names = [names {title}];
      
    end
  catch Me
    warning('Failed to generate figure names: %s', Me.message);
  end % End try
end

%--------------------------------------------------------------------------
% Plot fsdata objects
%
function varargout = fs_plot(varargin)
  
  aos = varargin{1};
  pl  = varargin{2};
  fig2plot = varargin{3};
  
  UseLatex = find_core(pl, 'LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % Extract parameters
  arrangement     = find_core(pl, 'Arrangement');
  linecolors      = find_core(pl, 'LineColors');
  linestyles      = find_core(pl, 'LineStyles');
  markers         = find_core(pl, 'Markers');
  markerSizes     = find_core(pl, 'MarkerSizes');
  linewidths      = find_core(pl, 'LineWidths');
  legends         = find_core(pl, 'Legends');
  legendsFont     = find_core(pl, 'LegendFontSize');
  ylabels         = find_core(pl, 'YLabels');
  xlabels         = find_core(pl, 'XLabels');
  titles          = find_core(pl, 'Titles');
  yscales         = find_core(pl, 'YScales');
  xscales         = find_core(pl, 'XScales');
  yranges         = find_core(pl, 'YRanges');
  xranges         = find_core(pl, 'XRanges');
  type            = find_core(pl, 'Function');
  legendLoc       = find_core(pl, 'LegendLocation');
  errorType       = find_core(pl, 'ErrorBarType');
  descOn          = find_core(pl, 'ShowDescriptions');
  if find_core(pl,'LatexLabels')
    legendInterp = 'latex';
  else
    legendInterp = 'none';
  end
  complexPlotType = find_core(pl, 'complexPlotType');
  autoErrors      = find_core(pl, 'AUTOERRORS');
  
  prefs = getappdata(0, 'LTPDApreferences');
  styles = prefs.getPlotstylesPrefs;
  
  % get errors
  XerrL       = find_core(pl, 'XerrL');
  XerrU       = find_core(pl, 'XerrU');
  YerrL       = find_core(pl, 'YerrL');
  YerrU       = find_core(pl, 'YerrU');
  if ~iscell(XerrU), XerrU = {XerrU}; end
  if ~iscell(XerrL), XerrL = {XerrL}; end
  if ~iscell(YerrU), YerrU = {YerrU}; end
  if ~iscell(YerrL), YerrL = {YerrL}; end
  if (numel(XerrL) > 1 && numel(XerrL) ~= numel(aos)) || ...
      (numel(YerrL) > 1 && numel(YerrL) ~= numel(aos)) || ...
      (numel(XerrU) > 1 && numel(XerrU) ~= numel(aos)) || ...
      (numel(YerrU) > 1 && numel(YerrU) ~= numel(aos))
    error('### Please specify 1 set of errors for all AOs, or a set of errors for each AO.');
  end
  
  % check whether we want legends or not
  if iscell(legends)
    legendsOn = 1;
  else
    if strcmpi(legends, 'off')
      legendsOn = 0;
    else
      legendsOn = 1;
      legends = [];
    end
  end
  
  
  if ~iscell(linewidths), linewidths = {linewidths}; end
  if ~iscell(linestyles), linestyles = {linestyles}; end
  if ~iscell(linecolors), linecolors = {linecolors}; end
  if ~iscell(markers), markers = {markers}; end
  if ~iscell(markerSizes), markerSizes = {markerSizes}; end
  if ~iscell(legends), legends = {legends}; end
  if ~iscell(ylabels), ylabels = {ylabels}; end
  if ~iscell(xlabels), xlabels = {xlabels}; end
  if ~iscell(titles), titles = {titles}; end
  if ~iscell(xscales), xscales = {xscales}; end
  if ~iscell(yscales), yscales = {yscales}; end
  if ~iscell(xranges), xranges = {xranges}; end
  if ~iscell(yranges), yranges = {yranges}; end
  
  % collect figure handles
  fsfig = []; fsax  = []; fsli  = [];
  % Legend holder
  legendStrR = [];
  legendStrI = [];
  % Helper variables
  ymin = Inf;
  ymax = -Inf;
  xmin = Inf;
  xmax = -Inf;
  complexFig   = [];
  complexAxes  = [];
  
  if ~isempty(aos)
    % Now loop over AOs
    Na = length(aos);
    % First to check if any are complex y data
    haveComplex = 0;
    for jj = 1:Na
      % Get data
      y = aos(jj).data.getY;
      % Is this a complex plot?
      if ~isreal(y)
        haveComplex = 1;
      end
    end
    
    % Do we want to use a unit placeholder on the yaxis?
    yunits = aos(1).data.yunits;
    yunitPlaceholder = '[Mixed]';
    useYunitPlaceholder = false;
    if strcmpi(arrangement, 'stacked')
      for jj = 1:Na
        if ~isequal(yunits, aos(jj).data.yunits)
          useYunitPlaceholder = true;
          break;
        end
      end
    end
    ylabeli = '';
    % Do we want to use a unit placeholder on the xaxis?
    xunits = aos(1).data.xunits;
    xunitPlaceholder = '[Mixed]';
    useXunitPlaceholder = false;
    if strcmpi(arrangement, 'stacked')
      for jj = 1:Na
        if ~isequal(xunits, aos(jj).data.xunits)
          useXunitPlaceholder = true;
          break;
        end
      end
    end
    
    % make sure we start counting styles at 0
    styles.resetStyleIndex();
    
    % No plot
    for jj = 1:Na
      
      if useYunitPlaceholder
        yunits = yunitPlaceholder;
      else
        yunits = aos(jj).data.yunits;
      end
      if useXunitPlaceholder
        xunits = xunitPlaceholder;
      else
        xunits = aos(jj).data.xunits;
      end
      % set real and imag subplot handles to empty
      fsax_r = [];
      fsax_i = [];
      % Get data
      x = aos(jj).data.getX; y = aos(jj).data.getY;
      % what figures do we need?
      switch arrangement
        case 'single'
          fsfig = [fsfig figure];
          style = styles.styleAtIndex(0);
          % check if this data set is real or complex
          if ~isreal(y)
            % complex means we use two subplots
            fsax_r = subplot(2,1,1); fsax_i = subplot(2,1,2);
            fsax   = [fsax fsax_r fsax_i];
            complexFig   = [complexFig get(fsax_r, 'Parent')];
            complexAxes  = [complexAxes fsax_r fsax_i];
          else
            % real means we use a single subplot
            fsax_r = subplot(1, 1, 1);
            fsax = [fsax fsax_r];
          end
          % Make sure we reset the helper variables in this case
          ymin = Inf; ymax = -Inf; xmin = Inf; xmax = -Inf;
        case 'stacked'
          if ~isempty(fig2plot), fsfig = fig2plot;
          elseif jj == 1, fsfig = figure;
          end
          % if at least one of the input fsdata AOs is complex, we need to
          % allow for subplots
          if haveComplex
            fsax_r = subplot(2,1,1,'Parent',fsfig); fsax_i = subplot(2,1,2,'Parent',fsfig);
            fsax   = [fsax_r fsax_i];
            if jj == 1
              complexFig   = [complexFig fsfig];
              complexAxes  = [complexAxes fsax_r fsax_i];
            end
          else
            fsax_r = subplot(1, 1, 1,'Parent',fsfig);
            fsax = fsax_r;
          end
          style = styles.nextStyle();
          hold(fsax_r, 'on');
          if ishandle(fsax_i)
            hold(fsax_i, 'on');
          end
        case 'subplots'
          if ~isempty(fig2plot), fsfig = fig2plot;
          elseif jj == 1, fsfig = figure;
          end
          c = 1+(jj-1)*2;
          sx = Na;
          sy = 2;
          % Now we have one or two subplots per input object.
          if ~isreal(y)
            fsax_r = subplot(sx, sy,c); fsax_i = subplot(sx, sy,c+1);
            fsax   = [fsax fsax_r fsax_i];
          else
            fsax_r = subplot(sx, sy, c:c+1);
            fsax   = [fsax fsax_r];
          end
          style = styles.styleAtIndex(0);
          % Make sure we reset the helper variables in this case
          ymin = Inf; ymax = -Inf; xmin = Inf; xmax = -Inf;
        otherwise
          error('### Unknown plot arrangement');
      end
      
      % cache a copy of the AO in the figure handle
      utils.plottools.cacheObjectInUserData(fsfig(end), aos(jj));
      
      % Process errors
      [fcn, xu, xl, yu, yl] = process_errors(jj, size(y), type, XerrU, XerrL, YerrU, YerrL, aos(jj), autoErrors);
      
      % workaround for bug in new MATLAB which really doesn't like
      % errorbars with x==0 and log scale
      
      if any(strcmp(fcn, {'errorbar', 'errorbarxy'}))
        idx = x>0;
        x = x(idx);
        y = y(idx);
        yl = yl(idx);
        yu = yu(idx);
        xl = xl(idx);
        xu = xu(idx);
      end
      
      %------- Plot the data
      
      % plot real or complex data and setup default values for scale and
      % labels as we go.
      errorH  = [];
      rerrorH = [];
      ierrorH = [];
      if isreal(y)
        % if the data are real, then we don't expect negative error bars
        idx = find(yl>abs(y));
        yl(idx) = 0.999*abs(y(idx));
        [li, le, errorH] = plotData(fsax_r, x, y, xu, xl, yl, yu, fcn, type, errorType);        
        fsli = [fsli li];
        
        ylabelr = find_core(pl, 'YLabels');
        ylabeli = 'imag';
        yscaleR = 'log'; yscaleI = 'lin';
        xscaleR = 'log'; xscaleI = 'log';
      else
        switch complexPlotType
          case 'realimag'
            switch fcn
              case 'errorbar'
                ry = real(y);
                ferr = yl./abs(y);
                yl = ry.*ferr;
                yu = ry.*ferr;
                [li, le, rerrorH] = plotData(fsax_r, x, ry, xu, xl, yl, yu, fcn, type, errorType);        
              case type
                li   = feval(type, fsax_r, x, real(y));
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_r, x, real(y), xu, yu, xl, yl);
                li = lhs(1);
                le = lhs(2);
            end
            switch fcn
              case 'errorbar'
                iy = imag(y);
                ferr = yl./abs(y);
                yl = iy.*ferr;
                yu = iy.*ferr;
                [ili, le, ierrorH] = plotData(fsax_i, x, iy, xu, xl, yl, yu, fcn, type, errorType);        
                li = [li ili];
              case type
                li   = [li feval(type, fsax_i, x, imag(y))];
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_i, x, imag(y), xu, yu, xl, yl);
                li = [li lhs(1)];
                le = lhs(2);
            end
            fsli = [fsli li];
            ylabelr = 'real'; ylabeli = 'imag';
            yscaleR = 'lin'; yscaleI = 'lin';
            xscaleR = 'log'; xscaleI = 'log';
          case 'absdeg'
            a = abs(y);
            p = utils.math.phase(y);
            % if the data are absolute values, then we don't expect
            % negative error bars
            idx = find(yl>abs(y));
            yl(idx) = 0.999*abs(y(idx));
            switch fcn
              case 'errorbar'
                [li, le, rerrorH] = plotData(fsax_r, x, a, xu, xl, yl, yu, fcn, type, errorType);        
              case type
                li   = feval(type, fsax_r, x, abs(y));
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_r, x, abs(y), xu, yu, xl, yl);
                li = lhs(1); le = lhs(2);
            end
            switch fcn
              case 'errorbar'
                ferr = yl./a;
                yl = 360.*ferr;
                yu = 360.*ferr;
                [ili, le, ierrorH] = plotData(fsax_i, x, p, xu, xl, yl, yu, fcn, type, errorType);        
                li = [li ili];
              case type
                li   = [li feval(type, fsax_i, x, utils.math.phase(y))];
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_i, x, utils.math.phase(y), xu, yu, xl, yl);
                li = [li lhs(1)]; le = lhs(2);
            end
            fsli = [fsli li];
            ylabelr = 'Amplitude'; ylabeli = 'Phase';
            yscaleR = 'log'; yscaleI = 'lin';
            xscaleR = 'log'; xscaleI = 'log';
          case 'absrad'
            % if the data are absolute values, then we don't expect
            % negative error bars
            idx = find(yl>abs(y));
            yl(idx) = 0.999*abs(y(idx));
            switch fcn
              case 'errorbar'
                [li, le, rerrorH] = plotData(fsax_r, x, abs(y), xu, xl, yl, yu, fcn, type, errorType);        
              case type
                li   = feval(type, fsax_r, x, abs(y));
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_r, x, abs(y), xu, yu, xl, yl);
                li = lhs(1); le = lhs(2);
            end
            switch fcn
              case 'errorbar'
                ferr = yl./abs(y);
                yl = pi.*ferr;
                yu = pi.*ferr;
                [ili, le, ierrorH] = plotData(fsax_i, x, angle(y), xu, xl, yl, yu, fcn, type, errorType);        
                li = [li ili];
              case type
                li   = [li feval(type, fsax_i, x, angle(y))];
                le   = false; % we have no error plots
              case 'errorbarxy'
                lhs = errorbarxy(fsax_i, x, angle(y), xu, yu, xl, yl);
                li = [li lhs(1)];
                le = lhs(2);
            end
            fsli = [fsli li];
            ylabelr = 'Amplitude'; ylabeli = 'Phase';
            yscaleR = 'log'; yscaleI = 'lin';
            xscaleR = 'log'; xscaleI = 'log';
          otherwise
            error('### Unknown plot type for complex data');
        end
      end
      
      %------- Axis properties
      % axis counter
      if ishandle(fsax_i)
        % Complex plot
        c = 1+(jj-1)*2;
      else
        % Real plot
        c = jj;
      end
      
      % set title
      titleStr = parseOptions(jj, titles, find_core(pl, 'titles'));
      titleStr = makeTitleStr(titleStr, UseLatex);
      if UseLatex
        title(titleStr, 'interpreter', 'latex');
      else
        title(titleStr);
      end
      
      % Set real axis ylabel
      ylstrR = parseOptions(c, ylabels, ylabelr);
      ylstrR = prepareAxisLabel(yunits, '', ylstrR, 'y', UseLatex, aos(jj));
      ylstrR = fixlabel(ylstrR);
      if UseLatex
        ylabel(fsax_r, ylstrR, 'interpreter', 'latex');
      else
        ylabel(fsax_r, ylstrR);
      end
      
      % Set imag axis ylabel
      if ishandle(fsax_i)
        ylstrI = parseOptions(c+1, ylabels, ylabeli);
        switch complexPlotType
          case 'realimag'
            ylstrI = prepareAxisLabel(yunits, '', ylstrI, 'y', UseLatex, aos(jj));
          case 'absdeg'
            ylstrI = prepareAxisLabel(unit('deg'), [], ylstrI, 'y', UseLatex, aos(jj));
          case 'absrad'
            ylstrI = prepareAxisLabel(unit('rad'), [], ylstrI, 'y', UseLatex, aos(jj));
          otherwise
        end
        ylstrI = fixlabel(ylstrI);
        if UseLatex
          ylabel(fsax_i, ylstrI, 'interpreter', 'latex');
        else
          ylabel(fsax_i, ylstrI);
        end
      end
      
      % Set xlabel
      xlstr = parseOptions(jj, xlabels, find_core(pl, 'XLabels'));
      xlstr = prepareAxisLabel(xunits, '', xlstr, 'x', UseLatex, aos(jj));
      xlstr = fixlabel(xlstr);
      if isreal(y)
        if UseLatex
          xlabel(fsax_r, xlstr, 'interpreter', 'latex');
        else
          xlabel(fsax_r, xlstr);
        end
      else
        % Do not draw Xlabel and XTicklabel on the real plot
        safeset(fsax_r, 'XTickLabel',[]);
      end
      if ~isempty(fsax_i) && ishandle(fsax_i)
        if UseLatex
          xlabel(fsax_i, xlstr, 'interpreter', 'latex');
        else
          xlabel(fsax_i, xlstr);
        end
      end
      
      % Set grid on or off
      grid(fsax_r, 'on');
      if ~isempty(fsax_i) && ishandle(fsax_i), grid(fsax_i, 'on'); end
      
      % Set Y scale
      yscaleR = parseOptions(c, yscales, yscaleR);
      yscaleI = parseOptions(c+1, yscales, yscaleI);
      safeset(fsax_r, 'YScale', yscaleR);
      if ~isempty(fsax_i) && ishandle(fsax_i), safeset(fsax_i, 'YScale', yscaleI); end
      
      % Set X scale
      xscaleR = parseOptions(c, xscales, xscaleR);
      xscaleI = parseOptions(c+1, xscales, xscaleI);
      safeset(fsax_r, 'XScale', xscaleR);
      if ~isempty(fsax_i) && ishandle(fsax_i)
        safeset(fsax_i, 'XScale', xscaleI);
      end
      
      % Set Y range
      yrange = parseOptions(c, yranges, []);
      if ~isempty(yrange)
        safeset(fsax_r, 'YLim', yrange);
      elseif strcmpi(yscaleR, 'log')
        [tcks,ymin,ymax] = getRealYDataTicks(y, ymin, ymax, complexPlotType, yscaleR);
        nticks = numel(tcks);
        if nticks>0 && nticks < 10
          yrange = [tcks(1) tcks(end)];
          safeset(fsax_r, 'YLim', yrange);
          safeset(fsax_r, 'Ytickmode', 'manual');
          safeset(fsax_r, 'Ytick', tcks);
        else
          % go back to matlab autoscale
          safeset(fsax_r, 'ylimmode', 'auto');
          safeset(fsax_r, 'Ytick', []);
          safeset(fsax_r, 'Ytickmode', 'auto');
          
        end
      end
      yrange = parseOptions(c+1, yranges, []);
      if ~isempty(fsax_i) && ishandle(fsax_i)
        if ~isempty(yrange)
          safeset(fsax_i, 'YLim', yrange);
        elseif strcmpi(yscaleI, 'log')
          
          % This doesn't really make sense since the imaginary part or
          % phase or angle will always contain negative parts. Would the
          % user really choose a log scale in that case?
          %           tcks = getImagYDataTicks(y, ymin, ymax, complexPlotType, yscaleI);
          %           if ~isempty(tcks)
          %             yrange = [tcks(1) tcks(end)];
          %             set(fsax_i, 'YLim', yrange);
          %             set(fsax_i, 'Ytickmode', 'manual');
          %             set(fsax_i, 'Ytick', tcks);
          %           end
        end
      end
      
      % Set X range
      xrange = parseOptions(c, xranges, []);
      if ~isempty(xrange)
        safeset(fsax_r, 'XLim', xrange);
      elseif strcmpi(xscaleR, 'log')
        xmin = min(xmin,  floor(log10(min(x(x>0)))));
        xmax = max(xmax, ceil(log10(max(x(x>0)))));
        tcks = logspace(xmin, xmax, xmax - xmin +1);
        xrange = [tcks(1) tcks(end)];
        safeset(fsax_r, 'XLim', xrange);
        safeset(fsax_r, 'Xtickmode', 'manual');
        safeset(fsax_r, 'Xtick', tcks);
      end
      xrange = parseOptions(c+1, xranges, []);
      if ~isempty(fsax_i) && ishandle(fsax_i)
        if ~isempty(xrange)
          safeset(fsax_i, 'XLim', xrange);
        elseif strcmpi(xscaleR, 'log')
          xmin = min(xmin, floor(log10(min(x(x>0)))));
          xmax = max(xmax, ceil(log10(max(x(x>0)))));
          tcks = logspace(xmin, xmax, xmax - xmin +1);
          xrange = [tcks(1) tcks(end)];
          safeset(fsax_i, 'XLim', xrange);
          safeset(fsax_i, 'Xtickmode', 'manual');
          safeset(fsax_i, 'Xtick', tcks);
        end
      end
      
      %------- line properties
      [col, lstyle, lwidth, mkr, mkrSize, mkrEdgeCol, mkrFaceCol] = parseLineProps(jj, aos(jj).plotinfo, ...
        linecolors,  style.getMATLABColor(),       ...
        linestyles,  char(style.getLinestyle()),   ...
        linewidths,  double(style.getLinewidth()), ...
        markers,     char(style.getMarker()),      ...
        markerSizes, double(style.getMarkersize));
      
      % set props
      safeset(li, 'Color', col);
      if strcmpi(errorType, 'area') && ~isempty(errorH)
        safeset(errorH.patch, 'FaceColor', col);
      end
      
      if strcmpi(errorType, 'area') && ~isempty(rerrorH)
        safeset(rerrorH.patch, 'FaceColor', col);
      end      
      
      if strcmpi(errorType, 'area') && ~isempty(ierrorH)
        safeset(ierrorH.patch, 'FaceColor', col);
      end      
      
      safeset(li, 'LineStyle', lstyle);
      safeset(li, 'LineWidth', lwidth);
      if numel(x) == 1 && numel(y) == 1 && strcmp(mkr, 'None')
        mkr = '.';
      end
      safeset(li, 'Marker', mkr);
      safeset(li, 'MarkerSize', mkrSize);
      safeset(li, 'MarkerFaceColor', mkrFaceCol);
      safeset(li, 'MarkerEdgeColor', mkrEdgeCol);
      
      % Set legend string
      if legendsOn
        if ~isempty(aos(jj).plotinfo)            && ...
            ~aos(jj).plotinfo.includeInLegend
          for kk=1:numel(li)
            safeset(get(get(li(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
          end
        else
          lstr = parseOptions(jj, legends, makeLegendStr(aos(jj), legendInterp, descOn));
          legendStrR = [legendStrR cellstr(lstr)];
          if ~isreal(y)
            legendStrI = [legendStrI cellstr(lstr)];
          end
          
          if strcmpi(errorType, 'area')
            % stop any patches from appearing in the legend. These come from
            % the area errorbar type.
            gca_ch = get(fsax_r, 'Children');
            for cc=1:numel(gca_ch)
              if strcmpi(get(gca_ch(cc), 'Type'), 'patch')
                safeset(get(get(gca_ch(cc),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
              end
            end
            gca_ch = get(fsax_i, 'Children');
            for cc=1:numel(gca_ch)
              if strcmpi(get(gca_ch(cc), 'Type'), 'patch')
                safeset(get(get(gca_ch(cc),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
              end
            end
          end
          
          if strcmp(arrangement, 'single') || strcmp(arrangement, 'subplots')
            legend(fsax_r, fixlabel(legendStrR(end)), 'Location', legendLoc, 'Interpreter', legendInterp);
            if ~isempty(fsax_i) && ishandle(fsax_i)
              h = legend(fsax_i, fixlabel(legendStrI(end)), 'Location', legendLoc, 'Interpreter', legendInterp);
            end
          end
        end
      end
      
    end % End loop over AOs
    
    % Make sure the plots are refreshed
    drawnow();
    % Trim the size of complex plots
    for jj = 1:length(complexFig)
      p_r = get(complexAxes(2*jj-1), 'Position');
      p_i = get(complexAxes(2*jj), 'Position');
      dh = (p_r(2) - (p_i(2)+p_i(4)))/3;
      safeset(complexAxes(2*jj-1), 'Position', [p_r(1) p_r(2)-dh p_r(3) p_r(4)+dh]);
      safeset(complexAxes(2*jj), 'Position', [p_i(1) p_i(2) p_i(3) p_i(4)+dh]);
    end
    
    % Process legends for stacked plots
    if legendsOn
      if strcmp(arrangement, 'stacked')
        if ~isempty(legendStrR)
          h = legend(fsax_r, fixlabel(legendStrR), 'Location', legendLoc, 'Interpreter', legendInterp);
          safeset(h, 'FontSize', legendsFont);
          if ~isempty(fsax_i) && ishandle(fsax_i)
            h = legend(fsax_i, fixlabel(legendStrI), 'Location', legendLoc, 'Interpreter', legendInterp);
            safeset(h, 'FontSize', legendsFont);
          end
        end
      end
    end
  end % End ~isempty AOs
  
  % Apply plot settings to the figure
  applyPlotSettings(fsax, fsli);
  
  % Synchronize limits of the x-axes
  if strcmp(arrangement, 'subplots')
    linkXaxes(fsax);
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = fsfig;
  end
  if nargout > 1
    varargout{2} = fsax;
  end
  if nargout == 3
    varargout{3} = fsli;
  end
  if nargout > 3
    error('### Too many output arguments');
  end
end % End fs_plot

function [li, le, errorH] = plotData(fsax_r, x, y, xu, xl, yl, yu, fcn, type, errorType)
  
  errorH = [];
  
  switch fcn
    case 'errorbar'
      if strcmpi(errorType, 'bar')
        li = errorbar(fsax_r, x, y, yl, yu);
      else
        axes(fsax_r);
        e = [yl yu]';
        % edge case. One can get very small errors which eventually become
        % zero in the dy field (after calculations). Then it doesn't draw
        % properly.
        
        % check if the errorbars are too small for plotting sensibly.
        if all(all(e == 0)) || (any(abs((yu-yl)./y) < eps(yu)) && ~all(yu==yl))
          e = [y y]';
        end
        errorH = shadedErrorBar(x, y, e, 'k', 1);
        li = errorH.mainLine;
      end
      le = false;
    case type
      li   = feval(type, fsax_r, x, y);
      le   = false; % we have no error plots
    case 'errorbarxy'
      
      if ~strcmpi(errorType, 'bar')
        warning('Errorbar type ''area'' is not supported for x and y errors together');
      end
      
      lhs = errorbarxy(fsax_r, x, y, xu, yu, xl, yl);
      li = lhs(1);
      le = lhs(2);
  end
end % end 

%--------------------------------------------------------------------------
% Plot tsdata and xydata objects
%
function varargout = xy_plot(varargin)
  
  aos = varargin{1};
  pl  = varargin{2};
  fig2plot = varargin{3};
  Na  = length(aos);
  
  UseLatex = find_core(pl, 'LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % Extract parameters
  arrangement = find_core(pl, 'Arrangement');
  linecolors  = find_core(pl, 'LineColors');
  linestyles  = find_core(pl, 'LineStyles');
  markers     = find_core(pl, 'Markers');
  markerSizes = find_core(pl, 'MarkerSizes');
  linewidths  = find_core(pl, 'LineWidths');
  legends     = find_core(pl, 'Legends');
  legendsFont = find_core(pl, 'LegendFontSize');
  ylabels     = find_core(pl, 'YLabels');
  xlabels     = find_core(pl, 'XLabels');
  titles      = find_core(pl, 'Titles');
  yranges     = find_core(pl, 'YRanges');
  xranges     = find_core(pl, 'XRanges');
  yscales     = find_core(pl, 'YScales');
  xscales     = find_core(pl, 'XScales');
  type        = find_core(pl, 'Function');
  legendLoc   = find_core(pl, 'LegendLocation');
  errorType       = find_core(pl, 'ErrorBarType');
  descOn          = find_core(pl, 'ShowDescriptions');
  if find_core(pl,'LatexLabels')
    legendInterp = 'latex';
  else
    legendInterp = 'none';
  end
  xunits      = find_core(pl, 'Xunits');
  autoErrors  = utils.prog.yes2true(find_core(pl, 'AUTOERRORS'));
  
  prefs = getappdata(0, 'LTPDApreferences');
  styles = prefs.getPlotstylesPrefs;
  
  % get errors
  XerrL       = find_core(pl, 'XerrL');
  XerrU       = find_core(pl, 'XerrU');
  YerrL       = find_core(pl, 'YerrL');
  YerrU       = find_core(pl, 'YerrU');
  if ~iscell(XerrU), XerrU = {XerrU}; end
  if ~iscell(XerrL), XerrL = {XerrL}; end
  if ~iscell(YerrU), YerrU = {YerrU}; end
  if ~iscell(YerrL), YerrL = {YerrL}; end
  if (numel(XerrL) > 1 && numel(XerrL) ~= numel(aos)) || ...
      (numel(YerrL) > 1 && numel(YerrL) ~= numel(aos)) || ...
      (numel(XerrU) > 1 && numel(XerrU) ~= numel(aos)) || ...
      (numel(YerrU) > 1 && numel(YerrU) ~= numel(aos))
    error('### Please specify 1 set of errors for all AOs, or a set of errors for each AO.');
  end
  
  torigin     = [];
  
  % check whether we want legends or not
  if iscell(legends)
    legendsOn = 1;
  else
    if strcmpi(legends, 'off')
      legendsOn = 0;
    else
      legendsOn = 1;
      legends = [];
    end
  end
  
  
  if ~iscell(linewidths), linewidths = {linewidths}; end
  if ~iscell(linestyles), linestyles = {linestyles}; end
  if ~iscell(linecolors), linecolors = {linecolors}; end
  if ~iscell(markers), markers = {markers}; end
  if ~iscell(markerSizes), markerSizes = {markerSizes}; end
  if ~iscell(legends), legends = {legends}; end
  if ~iscell(ylabels), ylabels = {ylabels}; end
  if ~iscell(xlabels), xlabels = {xlabels}; end
  if ~iscell(titles), titles = {titles}; end
  if ~iscell(xranges), xranges = {xranges}; end
  if ~iscell(yranges), yranges = {yranges}; end
  if ~iscell(xscales), xscales = {xscales}; end
  if ~iscell(yscales), yscales = {yscales}; end
  if ~iscell(xunits), xunits = {xunits}; end
  
  % override for xydata y and x axis labels
  for kk=1:numel(aos)
    if isa(aos(kk).data, 'xydata')
      xName = aos(kk).xaxisname;
      yName = aos(kk).yaxisname;
      % if we aren't using 'all'
      if numel(ylabels) ~= 2 || ~strcmpi(ylabels{1}, 'all')
        if ~strcmpi(yName, 'y') % not default, then use it
          ylabels{kk} = yName;
        end
      end
      % if we aren't using 'all'
      if numel(xlabels) ~= 2 || ~strcmpi(xlabels{1}, 'all')
        if ~strcmpi(xName, 'x') % not default, then use it
          xlabels{kk} = xName;
        end
      end
    end
  end
  
  
  % collect figure handles
  tsfig = []; tsax  = []; tsli  = []; tsle = [];
  % Legend holder
  legendStr = [];
  if ~isempty(aos)
    % Now loop over AOs to get earliest start time
    T0 = 0;
    if strcmp(arrangement, 'stacked')
      T0 = 1e50;
      for jj = 1:Na
        % Get this AO
        if isa(aos(jj).data, 'tsdata') && aos(jj).data.t0.double < T0
          T0 = aos(jj).data.t0.double;
        end
      end
    end
    
    % Do we want to use a unit placeholder on the yaxis?
    yunits = aos(1).data.yunits;
    yunitPlaceholder = '[Mixed]';
    useYunitPlaceholder = false;
    if strcmpi(arrangement, 'stacked')
      for jj = 1:Na
        if ~isequal(yunits, aos(jj).data.yunits)
          useYunitPlaceholder = true;
          break;
        end
      end
    end
    
    % Do we want to use a unit placeholder on the xaxis?
    firstXunits = aos(1).data.xunits;
    xunitPlaceholder = '[Mixed]';
    useXunitPlaceholder = false;
    if strcmpi(arrangement, 'stacked')
      for jj = 1:Na
        if ~isequal(firstXunits, aos(jj).data.xunits)
          useXunitPlaceholder = true;
          break;
        end
      end
    end
    
    % make sure we start counting styles at 0
    styles.resetStyleIndex();
    
    % Now loop over AOs
    for jj = 1:Na
      % Get this AO
      t0off = 0;
      
      if useYunitPlaceholder
        yunits = yunitPlaceholder;
      else
        yunits = aos(jj).data.yunits;
      end
      
      % what figures do we need?
      switch arrangement
        case 'single'
          tsfig = [tsfig figure];
          tsax = subplot(1,1,1);
          style = styles.styleAtIndex(0);
          if isa(aos(jj).data, 'tsdata')
            torigin = aos(jj).data.t0;
          end
        case 'stacked'
          if ~isempty(fig2plot), tsfig = fig2plot;
          elseif jj==1, tsfig = figure;
          end
          tsax = subplot(1,1,1,'Parent',tsfig);
          style = styles.nextStyle();
          hold on;
          % deal with time-stamps here
          if isa(aos(jj).data, 'tsdata')
            t0off = aos(jj).data.t0.double - T0;
          else
            t0off = 0;
          end
          if isa(aos(jj).data, 'tsdata')
            torigin = time(T0);
          end
        case 'subplots'
          if ~isempty(fig2plot), tsfig = fig2plot;
          elseif jj==1, tsfig = figure;
          end
          tsax = [tsax subplot(Na, 1, jj,'Parent',tsfig)];
          style = styles.styleAtIndex(0);
          if isa(aos(jj).data, 'tsdata')
            torigin = aos(jj).data.t0;
          end
        otherwise
          error('### Unknown plot arrangement');
      end
      
      % cache a copy of the AO in the figure handle
      utils.plottools.cacheObjectInUserData(tsfig(end), aos(jj));
      
      % Get data and add t0 offset for this time-series
      x = aos(jj).data.getX + t0off;
      y = aos(jj).data.getY;
      
      % Process X units
      if useXunitPlaceholder
        xunit = xunitPlaceholder;
        dateTicSpec = false;
      else
        if isa(aos(jj).data, 'tsdata')
          xunitIn  = char(aos(jj).data.xunits);
          xunit    = parseOptions(jj, xunits, xunitIn);
          [x, xunit, dateTicSpec] = utils.plottools.convertXunits(x, torigin, xunit, xunitIn);
        elseif isa(aos(jj).data, 'xydata')
          xunitIn  = char(aos(jj).data.xunits);
          xunit    = parseOptions(jj, xunits, xunitIn);
          dateTicSpec = false;
        else
          xunit = '';
          dateTicSpec = false;
        end
      end
      
      % Process errors
      [fcn, xu, xl, yu, yl] = process_errors(jj, size(y), type, XerrU, XerrL, YerrU, YerrL, aos(jj), autoErrors);
      if ~isempty(xu)
        xunitIn  = char(aos(jj).data.xunits);
        xunit    = parseOptions(jj, xunits, xunitIn);
        [xu, xunit, dateTicSpec] = utils.plottools.convertXunits(xu, torigin, xunit, xunitIn);
      end
      if ~isempty(xl)
        xunitIn  = char(aos(jj).data.xunits);
        xunit    = parseOptions(jj, xunits, xunitIn);
        [xl, xunit, dateTicSpec] = utils.plottools.convertXunits(xl, torigin, xunit, xunitIn);
      end
      
      %------- Plot the data
      errorH = [];
      switch fcn
        case 'errorbar'
          [li, le, errorH] = plotData(tsax(end), x, y, xu, xl, yl, yu, fcn, type, errorType);
          le = false;
        case type
          li   = feval(type, tsax(end), x, y);
          le   = false; % we have no error plots
        case 'errorbarxy'
          lhs = errorbarxy(tsax(end), x, y, xu, yu, xl, yl);
          li = lhs(1);
          le = lhs(2);
          tsle = [tsle le];
      end
      tsli = [tsli li];
      
      %------- Add time origin to the axis handle
      
      if isempty(torigin)
        torigin = time();
      end
      
      set(tsax(end), 'UserData', torigin)
      try
        dcm_obj = datacursormode(get(tsfig(end),'Parent'));
      catch
        dcm_obj = datacursormode(tsfig(end));
      end
      set(dcm_obj, 'UpdateFcn', @utils.plottools.datacursormode)
      
      %---------- Call datetic
      if dateTicSpec
        datetick(tsax(end), 'x', xunit(2:end-1), 'keeplimits');
      end
      
      %------- Axis properties
      
      % set title
      titleStr = parseOptions(jj, titles, find_core(pl, 'titles'));
      titleStr = makeTitleStr(titleStr, UseLatex);
      if UseLatex
        title(titleStr, 'interpreter', 'latex');
      else
        title(titleStr);
      end
      
      % Set ylabel
      ylstr = parseOptions(jj, ylabels, find_core(pl, 'YLabels'));
      ylstr = prepareAxisLabel(yunits, '', ylstr, 'y', UseLatex, aos(jj));
      ylstr = fixlabel(ylstr);
      if UseLatex
        ylabel(ylstr, 'interpreter', 'latex');
      else
        ylabel(ylstr);
      end
      
      % Set xlabel
      xlstr = parseOptions(jj, xlabels, find_core(pl, 'XLabels'));
      xlstr = prepareAxisLabel(xunit, '', xlstr, 'x', UseLatex, aos(jj));
      xlstr = fixlabel(xlstr);
      
      % if we have a time-series, write the time origin on the x-axis label
      if isa(aos(jj).data, 'tsdata') && find_core(pl, 'display time origin')
        fmt = pl.find_core('time format');
        xlstr = [sprintf('Origin: %s - ', torigin.format(fmt)) xlstr];
      end
      
      if UseLatex
        xlabel(xlstr, 'interpreter', 'latex');
      else
        xlabel(xlstr);
      end
      
      % Set Y range
      yrange = parseOptions(jj, yranges, []);
      if ~isempty(yrange), safeset(tsax(end), 'YLim', yrange); end
      
      % Set X range
      xrange = parseOptions(jj, xranges, []);
      switch class(xrange)
        case 'time'
          xrange = double(xrange - torigin);
        case 'timespan'
          xrange = xrange - torigin;
          xrange = double([xrange.startT xrange.endT]);
        otherwise
      end
      if ~isempty(xrange), safeset(tsax(end), 'XLim', xrange); end
      
      % Set Y scale
      yscale = parseOptions(jj, yscales, 'lin');
      safeset(tsax(end), 'YScale', yscale);
      
      % Set X scale
      xscale = parseOptions(jj, xscales, 'lin');
      safeset(tsax(end), 'XScale', xscale);
      
      % Set grid on or off
      grid(tsax(end), 'on');
      
      %------- line properties
      [col, lstyle, lwidth, mkr, mkrSize, mkrEdgeCol, mkrFaceCol] = parseLineProps(jj, aos(jj).plotinfo, ...
        linecolors,  style.getMATLABColor(),       ...
        linestyles,  char(style.getLinestyle()),   ...
        linewidths,  double(style.getLinewidth()), ...
        markers,     char(style.getMarker()),      ...
        markerSizes, double(style.getMarkersize));
      
      % Set line color
      if strcmpi(type, 'bar')
        safeset(li, 'EdgeColor', col);
        safeset(li, 'FaceColor', col);
      else
        safeset(li, 'Color', col);
      end
      
      if strcmpi(errorType, 'area') && ~isempty(errorH)
        safeset(errorH.patch, 'FaceColor', col);
      end
      
      
      if ~isempty(le) && ishandle(le), safeset(le, 'Color', col); end
      % Set line style
      safeset(li, 'LineStyle', lstyle);
      
      % Set markers
      if numel(x) == 1 && numel(y) == 1 && strcmp(mkr, 'None')
        mkr = '.';
      end
      safeset(li, 'Marker', mkr);
      safeset(li, 'MarkerSize', mkrSize);
      safeset(li, 'MarkerFaceColor', mkrFaceCol);
      safeset(li, 'MarkerEdgeColor', mkrEdgeCol);
      
      % Set line widths
      safeset(li, 'LineWidth', lwidth);
      if ~isempty(le) && ishandle(le), safeset(le, 'LineWidth', lwidth); end
      
      % Set legend string
      if ~isempty(le) && ishandle(le)
        safeset(get(get(le,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
      end
      
      if legendsOn
        if ~isempty(aos(jj).plotinfo)    && ...
            ~aos(jj).plotinfo.includeInLegend
          for kk=1:numel(li)
            safeset(get(get(li(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
          end
        else
          lstr = parseOptions(jj, legends, makeLegendStr(aos(jj), legendInterp, descOn));
          safeset(li, 'DisplayName', lstr);
          
          if strcmpi(errorType, 'area')
            % stop any patches from appearing in the legend. These come from
            % the area errorbar type.
            gca_ch = get(gca, 'Children');
            for cc=1:numel(gca_ch)
              if strcmpi(get(gca_ch(cc), 'Type'), 'patch')
                safeset(get(get(gca_ch(cc),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
              end
            end
          end
          
          
          legendStr = [legendStr cellstr(lstr)];
          % Set the legend now if we can
          if strcmp(arrangement, 'single') || strcmp(arrangement, 'subplots')
            legend(fixlabel(legendStr(end)), 'Location', legendLoc, 'Interpreter', legendInterp);
          end
        end
      end
    end
    
    % Process legends for stacked plots
    if legendsOn
      if strcmp(arrangement, 'stacked')
        if ~isempty(legendStr)
          h = legend(fixlabel(legendStr), 'Location', legendLoc, 'Interpreter', legendInterp);
          safeset(h, 'FontSize', legendsFont);
        end
      end
    end
  end % End if empty AOs
  
  % Apply plot settings to the figure
  applyPlotSettings(tsax, tsli);
  
  % Synchronize limits of the x-axes
  if strcmp(arrangement, 'subplots')
    linkXaxes(tsax);
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = tsfig;
  end
  if nargout > 1
    varargout{2} = tsax;
  end
  if nargout == 3
    varargout{3} = tsli;
  end
  if nargout > 3
    error('### Too many output arguments');
  end
end % end xy_plot

function safeset(hdl, prop, val)
  
  if isprop(hdl, prop)
    set(hdl, prop, val);
  end
  
end

%--------------------------------------------------------------------------
% Plot cdata objects
%
function varargout = y_plot(varargin)
  
  aos = varargin{1};
  pl  = varargin{2};
  fig2plot = varargin{3};
  
  UseLatex = find_core(pl, 'LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % Extract parameters
  arrangement = find_core(pl, 'Arrangement');
  linecolors  = find_core(pl, 'LineColors');
  linestyles  = find_core(pl, 'LineStyles');
  markers     = find_core(pl, 'Markers');
  markerSizes = find_core(pl, 'MarkerSizes');
  linewidths  = find_core(pl, 'LineWidths');
  legends     = find_core(pl, 'Legends');
  legendsFont = find_core(pl, 'LegendFontSize');
  ylabels     = find_core(pl, 'YLabels');
  xlabels     = find_core(pl, 'XLabels');
  titles      = find_core(pl, 'Titles');
  yranges     = find_core(pl, 'YRanges');
  xranges     = find_core(pl, 'XRanges');
  yscales     = find_core(pl, 'YScales');
  xscales     = find_core(pl, 'XScales');
  type        = find_core(pl, 'Function');
  legendLoc   = find_core(pl, 'LegendLocation');
  errorType       = find_core(pl, 'ErrorBarType');
  descOn          = find_core(pl, 'ShowDescriptions');
  if find_core(pl,'LatexLabels')
    legendInterp = 'latex';
  else
    legendInterp = 'none';
  end
  autoErrors  = find_core(pl, 'AUTOERRORS');
  
  prefs = getappdata(0, 'LTPDApreferences');
  styles = prefs.getPlotstylesPrefs;
  
  
  % get errors
  YerrL       = find_core(pl, 'YerrL');
  YerrU       = find_core(pl, 'YerrU');
  if ~iscell(YerrU), YerrU = {YerrU}; end
  if ~iscell(YerrL), YerrL = {YerrL}; end
  if (numel(YerrL) > 1 && numel(YerrL) ~= numel(aos)) || ...
      (numel(YerrU) > 1 && numel(YerrU) ~= numel(aos))
    error('### Please specify 1 set of errors for all AOs, or a set of errors for each AO.');
  end
  
  % check whether we want legends or not
  if iscell(legends)
    legendsOn = 1;
  else
    if strcmp(legends, 'off')
      legendsOn = 0;
    else
      legendsOn = 1;
      legends = [];
    end
  end
  
  
  if ~iscell(linewidths), linewidths = {linewidths}; end
  if ~iscell(linestyles), linestyles = {linestyles}; end
  if ~iscell(linecolors), linecolors = {linecolors}; end
  if ~iscell(markers), markers = {markers}; end
  if ~iscell(markerSizes), markerSizes = {markerSizes}; end
  if ~iscell(legends), legends = {legends}; end
  if ~iscell(ylabels), ylabels = {ylabels}; end
  if ~iscell(xlabels), xlabels = {xlabels}; end
  if ~iscell(titles), titles = {titles}; end
  if ~iscell(xranges), xranges = {xranges}; end
  if ~iscell(yranges), yranges = {yranges}; end
  if ~iscell(xscales), xscales = {xscales}; end
  if ~iscell(yscales), yscales = {yscales}; end
  
  % collect figure handles
  cfig = []; cax  = []; cli  = [];
  % Legend holder
  legendStr = [];
  if ~isempty(aos)
    
    % Now loop over AOs
    Na = length(aos);
    
    % Do we want to use a unit placeholder on the yaxis?
    yunits = aos(1).data.yunits;
    yunitPlaceholder = '[Mixed]';
    useYunitPlaceholder = false;
    if strcmpi(arrangement, 'stacked')
      for jj = 1:Na
        if ~isequal(yunits, aos(jj).data.yunits)
          useYunitPlaceholder = true;
          break;
        end
      end
    end
    
    % make sure we start counting styles at 0
    styles.resetStyleIndex();
    
    for jj = 1:Na
      if useYunitPlaceholder
        yunits = yunitPlaceholder;
      else
        yunits = aos(jj).data.yunits;
      end
      
      % what figures do we need?
      switch arrangement
        case 'single'
          cfig = [cfig figure];
          cax = subplot(1,1,1);
          style = styles.styleAtIndex(0);
        case 'stacked'
          if ~isempty(fig2plot), cfig = fig2plot;
          elseif jj==1, cfig = figure;
          end
          %           if jj==1, cfig = figure; end
          cax = subplot(1,1,1,'Parent',cfig);
          style = styles.nextStyle();
          hold on;
        case 'subplots'
          if ~isempty(fig2plot), cfig = fig2plot;
          elseif jj==1, cfig = figure;
          end
          %           if jj == 1, cfig = figure; end
          cax = [cax subplot(Na, 1, jj)];
          style = styles.styleAtIndex(0);
        otherwise
          error('### Unknown plot arrangement');
      end
      
      % cache a copy of the AO in the figure handle
      utils.plottools.cacheObjectInUserData(cfig(end), aos(jj));
      
      % Get data
      if isreal(aos(jj).data.getY)
        x = 1:length(aos(jj).data.getY);
        y = aos(jj).data.getY;
      else
        x = real(aos(jj).data.getY);
        y = imag(aos(jj).data.getY);
      end
      
      % Process errors
      [fcn, xu, xl, yu, yl] = process_errors(jj, size(y), type, {[]}, {[]}, YerrU, YerrL, aos(jj), autoErrors);
      
      %------- Plot the data
      switch fcn
        case 'errorbar'
          [lhs, le, errorH] = plotData(cax(end), x, y, xu, xl, yl, yu, fcn, type, errorType);        
%           lhs = errorbarxy(cax(end), x, y,zeros(size(yl)),yu,zeros(size(yl)),yl);
          idcs = lhs; %(1:end-1);
%           le = lhs(end);
        case type
          idcs   = feval(type, cax(end), x, y);
          le   = false; % we have no error plots
        case 'errorbarxy'
          lhs = errorbarxy(cax(end), x, y, xu, yu, xl, yl);
          idcs = lhs(1:end-1);
          le = lhs(end);
      end
      %------- Cache line handle for output
      cli = [cli idcs(1:end).'];
      
      %------- Axis properties
      
      % set title
      titleStr = parseOptions(jj, titles, find_core(pl, 'titles'));
      titleStr = makeTitleStr(titleStr, UseLatex);
      if UseLatex
        title(titleStr, 'interpreter', 'latex');
      else
        title(titleStr);
      end
      
      % Set ylabel
      ylstr = parseOptions(jj, ylabels, find_core(pl, 'YLabels'));
      ylstr = prepareAxisLabel(yunits, '', ylstr, 'y', UseLatex, aos(jj));
      ylstr = fixlabel(ylstr);
      if UseLatex
        ylabel(ylstr, 'interpreter', 'latex');
      else
        ylabel(ylstr);
      end
      
      % Set xlabel
      xlstr = parseOptions(jj, xlabels, find_core(pl, 'XLabels'));
      xlstr = prepareAxisLabel(unit('Index'), '', xlstr, 'x', UseLatex, aos(jj));
      xlstr = fixlabel(xlstr);
      if UseLatex
        xlabel(xlstr, 'interpreter', 'latex');
      else
        xlabel(xlstr);
      end
      
      % Set Y scale
      yscale = parseOptions(jj, yscales, 'lin');
      safeset(cax(end), 'YScale', yscale);
      
      % Set X scale
      xscale = parseOptions(jj, xscales, 'lin');
      safeset(cax(end), 'XScale', xscale);
      
      % Set Y range
      yrange = parseOptions(jj, yranges, []);
      if ~isempty(yrange), safeset(cax(end), 'YLim', yrange); end
      
      % Set X range
      xrange = parseOptions(jj, xranges, []);
      if ~isempty(xrange), safeset(cax(end), 'XLim', xrange); end
      
      % Set grid on or off
      grid(cax(end), 'on');
      
      %------- line properties
      [col, lstyle, lwidth, mkr, mkrSize, mkrEdgeCol, mkrFaceCol] = parseLineProps(jj, aos(jj).plotinfo, ...
        linecolors,  style.getMATLABColor(),       ...
        linestyles,  char(style.getLinestyle()),   ...
        linewidths,  double(style.getLinewidth()), ...
        markers,     char(style.getMarker()),      ...
        markerSizes, double(style.getMarkersize));
      
      % Overide line colors with user defined colors
      safeset(idcs, 'Color', col);
      if ~isempty(le) && ishandle(le), safeset(le, 'Color', col); end
      
      if strcmpi(errorType, 'area') && ~isempty(errorH)
        safeset(errorH.patch, 'FaceColor', col);
      end
      
      % Set line style
      safeset(idcs, 'LineStyle', lstyle);
      if ishandle(le), safeset(le, 'LineStyle', lstyle); end
      % Set Markers
      if numel(x) == 1 && numel(y) == 1 && strcmp(mkr, 'None')
        mkr = 'o';
      end
      safeset(idcs, 'Marker', mkr);
      safeset(idcs, 'MarkerSize', mkrSize);
      safeset(idcs, 'MarkerFaceColor', mkrFaceCol);
      safeset(idcs, 'MarkerEdgeColor', mkrEdgeCol);
      
      % Set line widths
      safeset(idcs, 'LineWidth', lwidth);
      if ~isempty(le) && ishandle(le), safeset(le, 'LineWidth', lwidth); end
      
      % Set legend string
      if legendsOn
        if ~isempty(aos(jj).plotinfo)            && ...
            ~aos(jj).plotinfo.includeInLegend
          for kk=1:numel(li)
            safeset(get(get(li(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
          end
        else
          
          if strcmpi(errorType, 'area')
            % stop any patches from appearing in the legend. These come from
            % the area errorbar type.
            gca_ch = get(gca, 'Children');
            for cc=1:numel(gca_ch)
              if strcmpi(get(gca_ch(cc), 'Type'), 'patch')
                safeset(get(get(gca_ch(cc),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
              end
            end
          end
          
          
          lstr = parseOptions(jj, legends, makeLegendStr(aos(jj), legendInterp, descOn));
          legendStr = [legendStr cellstr(lstr)];
          % Set the legend now if we can
          if strcmp(arrangement, 'single') || strcmp(arrangement, 'subplots')
            legend(fixlabel(legendStr(end)), 'Location', legendLoc, 'Interpreter', legendInterp);
          end
        end
      end
    end % End AO loop
    
    % Process legends for stacked plots
    if legendsOn
      if strcmp(arrangement, 'stacked')
        if ~isempty(legendStr)
          h = legend(fixlabel(legendStr), 'Location', legendLoc, 'Interpreter', legendInterp);
          safeset(h, 'FontSize', legendsFont);
        end
      end
    end
    
  end
  
  % Apply plot settings to the figure
  applyPlotSettings(cax, cli);
  
  % Synchronize limits of the x-axes
  if strcmp(arrangement, 'subplots')
    linkXaxes(cax);
  end
  
  
  % Set outputs
  if nargout > 0
    varargout{1} = cfig;
  end
  if nargout > 1
    varargout{2} = cax;
  end
  if nargout == 3
    varargout{3} = cli;
  end
  if nargout > 3
    error('### Too many output arguments');
  end
end % End y_plot

%--------------------------------------------------------------------------
% Plot tfmap objects
%
function varargout = tf_plot(varargin)
  
  aos = varargin{1};
  pl  = varargin{2};
  fig2plot = varargin{3};
  
  UseLatex = find_core(pl, 'LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % Extract parameters
  arrangement = find_core(pl, 'Arrangement');
  legends     = find_core(pl, 'Legends');
  legendsFont = find_core(pl, 'LegendFontSize');
  zlabels     = find_core(pl, 'ZLabels');
  ylabels     = find_core(pl, 'YLabels');
  xlabels     = find_core(pl, 'XLabels');
  legendLoc   = find_core(pl, 'LegendLocation');
  descOn          = find_core(pl, 'ShowDescriptions');
  if find_core(pl,'LatexLabels')
    legendInterp = 'latex';
  else
    legendInterp = 'none';
  end
  yranges     = find_core(pl, 'YRanges');
  xranges     = find_core(pl, 'XRanges');
  zranges     = find_core(pl, 'ZRanges');
  zscales     = find_core(pl, 'ZScales');
  yscales     = find_core(pl, 'YScales');
  xscales     = find_core(pl, 'XScales');
  invertY     = find_core(pl, 'InvertY');
  
  % check whether we want legends or not
  if iscell(legends)
    legendsOn = 1;
  else
    if strcmp(legends, 'off')
      legendsOn = 0;
    else
      legendsOn = 1;
      legends = [];
    end
  end
  
  
  if ~iscell(legends), legends = {legends}; end
  if ~iscell(ylabels), ylabels = {ylabels}; end
  if ~iscell(xlabels), xlabels = {xlabels}; end
  if ~iscell(zlabels), zlabels = {zlabels}; end
  if ~iscell(xranges), xranges = {xranges}; end
  if ~iscell(yranges), yranges = {yranges}; end
  if ~iscell(zranges), zranges = {zranges}; end
  if ~iscell(xscales), xscales = {xscales}; end
  if ~iscell(yscales), yscales = {yscales}; end
  if ~iscell(zscales), zscales = {zscales}; end
  
  
  % collect figure handles
  tdfig = [];
  tdax  = [];
  tdli  = [];
  
  % Legend holder
  legendStr = [];
  
  if ~isempty(aos)
    
    % Now loop over AOs
    Na = length(aos);
    for jj = 1:Na
      % what figures do we need?
      switch arrangement
        case 'single'
          tdfig = [tdfig figure];
          tdax = subplot(1,1,1);
        case 'subplots'
          if ~isempty(fig2plot), tdfig = fig2plot;
          elseif jj==1, tdfig = figure;
          end
          %           if jj == 1, tdfig = figure; end
          tdax = [tdax subplot(Na, 1, jj)];
        otherwise
          warning('!!! Plot arrangement ''%s'' not supported on XYZ plots. Using ''single'' instead.', arrangement);
          arrangment = 'single';
          tdfig = [tdfig figure];
          tdax = subplot(1,1,1);
      end
      
      % cache a copy of the AO in the figure handle
      utils.plottools.cacheObjectInUserData(tdfig(end), aos(jj));
      
      x = aos(jj).data.getX;
      y = aos(jj).data.getY;
      z = aos(jj).data.getZ;
      
      %------- Plot the data
      
      idcs = pcolor(x,y,z);
      tdli = [tdli idcs(1:end).'];
      
      % plot properties
      safeset(idcs, 'EdgeColor', 'none');
      
      %------- Axis properties
      
      % Reverse y-direction for spectrograms
      if invertY
        safeset(tdax(end), 'YDir', 'reverse');
      end
      
      % Set ylabel
      ylstr = parseOptions(jj, 'Frequency', find_core(pl, 'YLabels'));
      ylstr = prepareAxisLabel(aos(jj).data.yunits, '', ylstr, 'y', UseLatex, aos(jj));
      ylstr = fixlabel(ylstr);
      if UseLatex
        ylabel(ylstr, 'interpreter', 'latex');
      else
        ylabel(ylstr);
      end
      
      % Set xlabel
      xlstr = parseOptions(jj, sprintf('Time since %s', char(aos(jj).t0)), find_core(pl, 'XLabels'));
      xlstr = prepareAxisLabel(aos(jj).data.xunits, '', xlstr, 'x', UseLatex, aos(jj));
      xlstr = fixlabel(xlstr);
      if UseLatex
        xlabel(xlstr, 'interpreter', 'latex');
      else
        xlabel(xlstr);
      end
      
      % Set grid on or off
      grid(tdax(end), 'on');
      
      % Set title string
      if legendsOn
        if ~isempty(aos(jj).plotinfo)            && ...
            ~aos(jj).plotinfo.includeInLegend
          for kk=1:numel(li)
            safeset(get(get(li(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
          end
        else
          lstr = parseOptions(jj, legends, makeLegendStr(aos(jj), legendInterp, descOn));
          legendStr = [legendStr cellstr(lstr)];
          % Set the legend now if we can
          title(legendStr{end});
        end
      end
      
      % Set colorbars
      hc = colorbar('peer', tdax(end));
      zlstr = parseOptions(jj, zlabels, find_core(pl, 'Zlabels'));
      zlstr = prepareAxisLabel(aos(jj).data.zunits, '', zlstr, 'z', UseLatex, aos(jj));
      zlstr = fixlabel(zlstr);
      ylh = get(hc, 'YLabel');
      safeset(ylh, 'String', zlstr);
      safeset(ylh, 'Fontsize', get(tdax(end), 'Fontsize'))
      safeset(ylh, 'FontName', get(tdax(end), 'FontName'))
      safeset(ylh, 'FontAngle', get(tdax(end), 'FontAngle'))
      safeset(ylh, 'FontWeight', get(tdax(end), 'FontWeight'))
      
      
      % Set Y scale
      yscale = parseOptions(jj, yscales, 'lin');
      safeset(tdax(end), 'YScale', yscale);
      
      % Set X scale
      xscale = parseOptions(jj, xscales, 'lin');
      safeset(tdax(end), 'XScale', xscale);
      
      % Set Z scale
      zscale = parseOptions(jj, zscales, 'lin');
      safeset(tdax(end), 'ZScale', zscale);
      
      % Set Y range
      yrange = parseOptions(jj, yranges, []);
      if ~isempty(yrange), set(tdax(end), 'YLim', yrange); end
      
      % Set X range
      xrange = parseOptions(jj, xranges, []);
      if ~isempty(xrange), set(tdax(end), 'XLim', xrange); end
      
      % Set Z range
      zrange = parseOptions(jj, zranges, []);
      if ~isempty(zrange), set(tdax(end), 'CLim', zrange); end
    end
  end
  
  % Apply plot settings to the figure
  applyPlotSettings(tdax, tdli);
  
  % Synchronize limits of the x-axes
  if strcmp(arrangement, 'subplots')
    linkXaxes(tdax);
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = tdfig;
  end
  if nargout > 1
    varargout{2} = tdax;
  end
  if nargout == 3
    varargout{3} = tdli;
  end
  if nargout > 3
    error('### Too many output arguments');
  end
  
end % End tf_plot

%--------------------------------------------------------------------------
% Plot xyzdata objects
%
function varargout = xyz_plot(varargin)
  
  aos = varargin{1};
  pl  = varargin{2};
  fig2plot = varargin{3};
  
  UseLatex = find_core(pl, 'LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % Extract parameters
  arrangement = find_core(pl, 'Arrangement');
  legends     = find_core(pl, 'Legends');
  legendsFont = find_core(pl, 'LegendFontSize');
  zlabels     = find_core(pl, 'ZLabels');
  ylabels     = find_core(pl, 'YLabels');
  xlabels     = find_core(pl, 'XLabels');
  legendLoc   = find_core(pl, 'LegendLocation');
  func3D      = find_core(pl, 'Function3D');
  
  if find_core(pl,'LatexLabels')
    legendInterp = 'latex';
  else
    legendInterp = 'none';
  end
  yranges     = find_core(pl, 'YRanges');
  xranges     = find_core(pl, 'XRanges');
  zranges     = find_core(pl, 'ZRanges');
  zscales     = find_core(pl, 'ZScales');
  yscales     = find_core(pl, 'YScales');
  xscales     = find_core(pl, 'XScales');
  invertY     = find_core(pl, 'InvertY');
  descOn      = find_core(pl, 'ShowDescriptions');
  
  % check whether we want legends or not
  if iscell(legends)
    legendsOn = 1;
  else
    if strcmp(legends, 'off')
      legendsOn = 0;
    else
      legendsOn = 1;
      legends = [];
    end
  end
  
  
  if ~iscell(legends), legends = {legends}; end
  if ~iscell(ylabels), ylabels = {ylabels}; end
  if ~iscell(xlabels), xlabels = {xlabels}; end
  if ~iscell(zlabels), zlabels = {zlabels}; end
  if ~iscell(xranges), xranges = {xranges}; end
  if ~iscell(yranges), yranges = {yranges}; end
  if ~iscell(zranges), zranges = {zranges}; end
  if ~iscell(xscales), xscales = {xscales}; end
  if ~iscell(yscales), yscales = {yscales}; end
  if ~iscell(zscales), zscales = {zscales}; end
  
  
  % collect figure handles
  tdfig = [];
  tdax  = [];
  tdli  = [];
  
  % Legend holder
  legendStr = [];
  
  if ~isempty(aos)
    
    % Now loop over AOs
    Na = length(aos);
    for jj = 1:Na
      % what figures do we need?
      switch arrangement
        case 'single'
          tdfig = [tdfig figure];
          tdax = subplot(1,1,1);
        case 'subplots'
          if ~isempty(fig2plot), tdfig = fig2plot;
          elseif jj==1, tdfig = figure;
          end
          %           if jj == 1, tdfig = figure; end
          tdax = [tdax subplot(Na, 1, jj)];
        otherwise
          warning('!!! Plot arrangement ''%s'' not supported on XYZ plots. Using ''single'' instead.', arrangement);
          arrangment = 'single';
          tdfig = [tdfig figure];
          tdax = subplot(1,1,1);
      end
      
      % cache a copy of the AO in the figure handle
      utils.plottools.cacheObjectInUserData(tdfig(end), aos(jj));
      
      x = aos(jj).data.x;
      y = aos(jj).data.getY;
      z = aos(jj).data.z;
      
      %------- Plot the data
      
      idcs = feval(func3D, x,y,z);
      tdli = [tdli idcs(1:end).'];
      
      % plot properties
      safeset(idcs, 'EdgeColor', 'none');
      
      %------- Axis properties
      
      % Reverse y-direction for spectrograms
      if invertY
        safeset(tdax(end), 'YDir', 'reverse');
      end
      
      % Set ylabel
      ylstr = parseOptions(jj, ylabels, find_core(pl, 'YLabels'));
      ylstr = prepareAxisLabel(aos(jj).data.yunits, '', ylstr, 'y', UseLatex, aos(jj));
      ylstr = fixlabel(ylstr);
      if UseLatex
        ylabel(ylstr, 'interpreter', 'latex');
      else
        ylabel(ylstr);
      end
      
      % Set xlabel
      xlstr = parseOptions(jj, xlabels, find_core(pl, 'XLabels'));
      xlstr = prepareAxisLabel(aos(jj).data.xunits, '', xlstr, 'x', UseLatex, aos(jj));
      xlstr = fixlabel(xlstr);
      if UseLatex
        xlabel(xlstr, 'interpreter', 'latex');
      else
        xlabel(xlstr);
      end
      
      % Set grid on or off
      grid(tdax(end), 'on');
      
      % Set title string
      if legendsOn
        if ~isempty(aos(jj).plotinfo)            && ...
            ~aos(jj).plotinfo.includeInLegend
          for kk=1:numel(li)
            safeset(get(get(li(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
          end
        else
          lstr = parseOptions(jj, legends, makeLegendStr(aos(jj), legendInterp, descOn));
          legendStr = [legendStr cellstr(lstr)];
          % Set the legend now if we can
          title(legendStr{end});
        end
      end
      
      % Set colorbars
      hc = colorbar('peer', tdax(end));
      zlstr = parseOptions(jj, zlabels, find_core(pl, 'Zlabels'));
      zlstr = prepareAxisLabel(aos(jj).data.zunits, '', zlstr, 'z', UseLatex, aos(jj));
      zlstr = fixlabel(zlstr);
      ylh = get(hc, 'YLabel');
      safeset(ylh, 'String', zlstr);
      safeset(ylh, 'Fontsize', get(tdax(end), 'Fontsize'))
      safeset(ylh, 'FontName', get(tdax(end), 'FontName'))
      safeset(ylh, 'FontAngle', get(tdax(end), 'FontAngle'))
      safeset(ylh, 'FontWeight', get(tdax(end), 'FontWeight'))
      
      
      % Set Y scale
      yscale = parseOptions(jj, yscales, 'lin');
      safeset(tdax(end), 'YScale', yscale);
      
      % Set X scale
      xscale = parseOptions(jj, xscales, 'lin');
      safeset(tdax(end), 'XScale', xscale);
      
      % Set Z scale
      zscale = parseOptions(jj, zscales, 'lin');
      safeset(tdax(end), 'ZScale', zscale);
      
      % Set Y range
      yrange = parseOptions(jj, yranges, []);
      if ~isempty(yrange), safeset(tdax(end), 'YLim', yrange); end
      
      % Set X range
      xrange = parseOptions(jj, xranges, []);
      if ~isempty(xrange), safeset(tdax(end), 'XLim', xrange); end
      
      % Set Z range
      zrange = parseOptions(jj, zranges, []);
      if ~isempty(zrange), safeset(tdax(end), 'CLim', zrange); end
    end
  end
  
  % Apply plot settings to the figure
  applyPlotSettings(tdax, tdli);
  
  % Synchronize limits of the x-axes
  if strcmp(arrangement, 'subplots')
    linkXaxes(tdax);
  end
  
  % Set outputs
  if nargout > 0
    varargout{1} = tdfig;
  end
  if nargout > 1
    varargout{2} = tdax;
  end
  if nargout == 3
    varargout{3} = tdli;
  end
  if nargout > 3
    error('### Too many output arguments');
  end
end % end xyz_plot

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1&& ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = {'Time-series Plot', 'Frequency-series Plot', 'Y Data Plot', 'X-Y Data Plot', '3D Plot'};
    % get plists
    pl(size(sets)) = plist;
    for k = 1:numel(sets)
      pl(k) =  getDefaultPlist(sets{k});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
end

% Parse line properties from plist, or defaults
function [col, lstyle, lwidth, mkr, mkrSize, mkrEdgeCol, mkrFaceCol] = parseLineProps(jj, pli, ...
    linecolors,  dcol,    ...
    linestyles,  dlstyle, ...
    linewidths,  dlwidth, ...
    markers,     dmkr,    ...
    markerSizes, dmkrsize)
  
  fillMarkers = false;
  mkrEdgeCol = 'auto';
  mkrFaceCol = 'auto';
  
  % override defaults with plotinfo
  if ~isempty(pli) && ~isempty(pli.style)
    dcol     = pli.style.getMATLABColor();
    dlstyle  = char(pli.style.getLinestyle());
    dlwidth  = double(pli.style.getLinewidth());
    dmkr     = char(pli.style.getMarker());
    dmkrsize = double(pli.style.getMarkersize());
    mkrEdgeCol = utils.prog.jcolor2mcolor(pli.style.getMarkerEdgeColor());
    mkrFaceCol = utils.prog.jcolor2mcolor(pli.style.getMarkerFaceColor());
    fillMarkers = logical(pli.style.getFillmarkers.booleanValue());
  end
  
  
  % Set line color but overide with user colors
  col = parseOptions(jj, linecolors, dcol);
  
  % Set line style
  lstyle = parseOptions(jj, linestyles, dlstyle);
  
  % Set line widths
  lwidth = parseOptions(jj, linewidths, dlwidth);
  
  % Set markers
  mkr = parseOptions(jj, markers, dmkr);
  
  % Set markers size
  mkrSize = parseOptions(jj, markerSizes, dmkrsize);
  
  if ~fillMarkers
    mkrFaceCol = 'none';
  end
  
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
  pl.pset('LEGENDFONTSIZE', LTPDAprefs.legendFontSize);
  plout = pl;
end

function out = buildplist(set)
  
  out = plist();
  
  % Figure
  p = param({'Figure',['The handle of the figure to plot in to. This will be ignored if the AOs to plot are inconsistent,<br>'...
    'containing different class of data (such as tsdata and fsdata), or if the ''arrangement''<br>',...
    'parameter is passed as ''single''.']}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % Arrangement
  p = param({'Arrangement',['Select the plot layout:<ul>',...
    '<li>''single''   - plot all AOs on individual figures</li>',...
    '<li>''stacked''  - plot all AOs on the same axes</li>',...
    '<li>''subplots'' - plot all AOs on subplots</li>'...
    '</ul>']}, {1, {'stacked', 'single', 'subplots'}, paramValue.SINGLE});
  out.append(p);
  
  % Function
  p = param({'Function',['Specify the plot function:<ul>',...
    '<li>''plot''</li>', ...
    '<li>''stairs''</li>',...
    '<li>''stem''</li>',...
    '</ul>'...
    '[*** doesn''t work for xyzdata AOs]']}, {1, {'plot', 'stairs', 'stem'}, paramValue.SINGLE});
  out.append(p);
  
  % Function
  p = param({'Function3D',['Specify the plot function:<ul>',...
    '<li>''pcolor''</li>', ...
    '<li>''surf''</li>',...
    '<li>''mesh''</li>',...
    '</ul>']}, {1, {'pcolor', 'surf', 'mesh'}, paramValue.SINGLE});
  out.append(p);
 
  
  % LineColors
  p = param({'LineColors', ['A cell-array of color definitions, one for each trace.<br>'...
    'Give an empty string to use the default color.']}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % LineStyles
  p = param({'LineStyles', ['A cell-array of line styles, one for each trace.<br>'...
    'Give an empty string to use the default style.']}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % Markers
  p = param({'Markers', 'A cell-array of markers, one for each trace.'}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % Marker Sizes
  p = param({'MarkerSizes', 'A cell-array of marker sizes, one for each trace.'}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % LineWidths
  p = param({'LineWidths', ['A cell-array of line widths, one for each trace.<br>'...
    'Give an empty string to use the default line width.']}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % Legends
  p = param({'Legends', ['Give a cell-array of strings to be used for<br>'...
    'the plot legends. If a cell contains an empty<br>'...
    'string, the default legend string is built.<br>'...
    'If a single string ''off'' is given instead of a<br>'...
    'cell-array, then the legends are all switched off.']}, ...
    {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % LegendLocation
  p = param({'LegendLocation','Choose the legend location.'}, ...
    {5, {'North', 'South', 'East', 'West', ...
    'NorthEast', 'NorthWest', 'SouthEast', 'SouthWest', ...
    'NorthOutside', 'SouthOutside', 'EastOutside', 'WestOutside', ...
    'NorthEastOutside', 'NorthWestOutside', 'SouthEastOutside', ...
    'SouthWestOutside', 'Best', 'BestOutside'}, paramValue.SINGLE});
  out.append(p);
  
  % LegendFontSize
  p = param({'LegendFontSize','Choose the legend font size.'}, ...
    {1, {LTPDAprefs.legendFontSize}, paramValue.SINGLE});
  out.append(p);
  
  % showdescriptions
  p = param({'showdescriptions','Include object descriptions in the legend string.'}, paramValue.FALSE_TRUE);
  out.append(p);
  
  % FigureNames
  p = param({'FigureNames','Sets the figure name.'}, paramValue.EMPTY_STRING);
  out.append(p);
  
  % include provenance patch
  p = param({'show provenance', 'A flag to enable/disable the provenance text patch.'}, paramValue.TRUE_FALSE);
  out.append(p);
  
  % XerrL
  p = param({'XerrL','Lower bound error values for the X data points.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % XerrU
  p = param({'XerrU','Upper bound error values for the X data points.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % YerrL
  p = param({'YerrL','Lower bound error values for the Y data points.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % YerrU
  p = param({'YerrU','Upper bound error values for the Y data points.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % XScales
  p = param({'XScales', ['A cell-array specifying the scale to be used on each x-axis.<br>'...
    'For example, {''lin'', ''log''}']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % YScales
  p = param({'YScales', ['A cell-array specifying the scale to be used on each y-axis.<br>'...
    'For example, {''lin'', ''log''}']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % XRanges
  p = param({'XRanges', ['A cell-array specifying the ranges to be displayed on each x-axis.<br>'...
    'For example, {[0 1], [-4 4]}.']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % YRanges
  p = param({'YRanges', ['A cell-array specifying the ranges to be displayed on each y-axis.<br>'...
    'For example, {[0 1], [-4 4]}.']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % Titles
  p = param({'Titles', 'A cell-array specifying the titles to be displayed above each set of axes.<br>'}, ...
    {1, {''}, paramValue.OPTIONAL});
  p.addAlternativeKey('title');
  out.append(p);
  
  % LatexLabels
  p = param({'LatexLabels','Use latex interpreter for axis labels.'}, paramValue.FALSE_TRUE);
  out.append(p);
  
  % No auto-errors
  p = param({'AUTOERRORS',['If the AO contains errors, they will be plotted. You can avoid plotting the <br>',...
    'errors by setting this to false.']}, paramValue.FALSE_TRUE);
  out.append(p);
  
  % ErrorBarType
  p = param({'ErrorBarType',['Choose the way the errors should be displayed.']}, {1, {'bar', 'area'}, paramValue.SINGLE});
  out.append(p);  
  
  switch lower(set)
    case 'frequency-series plot'
      % ComplexPlotType
      p = param({'complexPlotType',['Specify how to plot complex data. Choose from:<ul>',...
        '<li>''realimag''</li>',...
        '<li>''absdeg''</li>',...
        '<li>''absrad''</li>'...
        '</ul>']}, {1, {'absdeg', 'realimag', 'absrad'}, paramValue.SINGLE});
      out.append(p);
      
      % Xlabel
      p = param({'XLabels',['Specify the labels to be used on the x-axes. The units are added from<br>',...
        'the data object ''xunits'' property.']}, paramValue.STRING_VALUE('Frequency'));
      out.append(p);
      % ylabels
      p = param({'YLabels',['Specify the labels to be used on the y-axes. The units are added from<br>',...
        'the data object ''yunits'' property.']}, paramValue.STRING_VALUE(''));
      out.append(p);
      
      
    case 'time-series plot'
      
      % Xlabel
      p = param({'XLabels',['Specify the labels to be used on the x-axes. The units are added from<br>',...
        'the data object ''xunits'' property.']}, paramValue.STRING_VALUE('Time'));
      out.append(p);
      
      % Ylabels
      p = param({'YLabels',['Specify the labels to be used on the y-axes. The units are added from<br>',...
        'the data object ''yunits'' property.']}, paramValue.STRING_VALUE('Amplitude'));
      out.append(p);
      
      % Xunits
      p = param({'Xunits', ['Specify the units of time on the x-axis as<ul>'...
        '<li>''us''        - microseconds<li>' ...
        '<li>''ms''        - milliseconds<li>' ...
        '<li>''s''         - seconds<li>' ...
        '<li>''m''         - minutes<li>' ...
        '<li>''h''         - hours<li>' ...
        '<li>''D''         - days<li>' ...
        '<li>''M''         - months<li>' ...
        '<li>''HH:MM:SS''  - using a date/time format</li>' ...
        '</ul>']}, {3, {'us', 'ms', 's', 'm', 'h', 'D', 'M', 'HH:MM:SS', 'yyyy-mm-dd HH:MM:SS'}, paramValue.OPTIONAL});
      out.append(p);
     
      % Invert y-axis
      p = param({'display time origin', 'True-False flag to display the origin time of the data.'}, paramValue.TRUE_FALSE);
      out.append(p);
      
      % time format
      p = param({'Time format', 'Specify the format used to display the time origin which prefixes the x-axis label. See help time/format.'}, ...
        paramValue.STRING_VALUE('yyyy-mm-dd HH:MM:SS.FFF'));
      out.append(p);
      
      
    case 'x-y data plot'
      % Xlabel
      p = param({'XLabels',['Specify the labels to be used on the x-axes. The units are added from<br>',...
        'the data object ''xunits'' property.']}, paramValue.STRING_VALUE('X-data'));
      out.append(p);
      
      % Ylabels
      p = param({'YLabels',['Specify the labels to be used on the y-axes. The units are added from<br>',...
        'the data object ''yunits'' property.']}, paramValue.STRING_VALUE('Y-data'));
      out.append(p);
      
      
    case '3d plot'
      
      out.pset('arrangement', 'single');
      
      % Xlabel
      p = param({'XLabels',['Specify the labels to be used on the x-axes. The units are added from<br>',...
        'the data object ''xunits'' property.']}, paramValue.EMPTY_STRING);
      out.append(p);
      
      % Ylabels
      p = param({'YLabels',['Specify the labels to be used on the y-axes. The units are added from<br>',...
        'the data object ''yunits'' property.']}, paramValue.EMPTY_STRING);
      out.append(p);
      
      % Zlabels
      p = param({'ZLabels',['Specify the labels to be used on the z-axes. The units are added from<br>',...
        'the data object ''zunits'' property.']}, paramValue.EMPTY_STRING);
      out.append(p);
      
      % ZScales
      p = param({'ZScales', ['A cell-array specifying the scale to be used on each z-axis.<br>'...
        'For example, {''lin'', ''log''}']}, {1, {''}, paramValue.OPTIONAL});
      out.append(p);
      
      % ZRanges
      p = param({'ZRanges', ['A cell-array specifying the ranges to be displayed on each z-axis.<br>'...
        'For example, {[0 1], [-4 4]}.']}, {1, {''}, paramValue.OPTIONAL});
      out.append(p);
      
      % Invert y-axis
      p = param({'InvertY', 'Invert the y-axis or not.'}, paramValue.TRUE_FALSE);
      out.append(p);
      
      out.remove('linestyles');
      out.remove('linewidths');
      out.remove('linecolors');
      out.remove('markers');
      out.remove('markersizes');
      
    case 'time-frequency plot'
      
      out.pset('arrangement', 'single');
      
      % Zlabels
      p = param({'ZLabels',['Specify the labels to be used on the z-axes. The units are added from<br>',...
        'the data object ''zunits'' property.']}, paramValue.STRING_VALUE('Amplitude'));
      out.append(p);
      
      % ZScales
      p = param({'ZScales', ['A cell-array specifying the scale to be used on each z-axis.<br>'...
        'For example, {''lin'', ''log''}']}, {1, {''}, paramValue.OPTIONAL});
      out.append(p);
      
      % ZRanges
      p = param({'ZRanges', ['A cell-array specifying the ranges to be displayed on each z-axis.<br>'...
        'For example, {[0 1], [-4 4]}.']}, {1, {''}, paramValue.OPTIONAL});
      out.append(p);
      
      % Invert y-axis
      p = param({'InvertY', 'Invert the y-axis or not.'}, paramValue.TRUE_FALSE);
      out.append(p);
      
      out.remove('linestyles');
      out.remove('linewidths');
      out.remove('linecolors');
      out.remove('markers');
      out.remove('markersizes');
      
    case 'y data plot'
      % Xlabel
      p = param({'XLabels',['Specify the labels to be used on the x-axes. The units are added from<br>',...
        'the data object ''xunits'' property.']}, paramValue.STRING_VALUE('Sample'));
      out.append(p);
      
      % Ylabels
      p = param({'YLabels',['Specify the labels to be used on the y-axes. The units are added from<br>',...
        'the data object ''yunits'' property.']}, paramValue.STRING_VALUE('Value'));
      out.append(p);
    otherwise
      error('### Unknown set [%s]', set);
  end
end

function name = makeTitleStr(str, legendInterp)
  
  str = fixlabel(str);
  
  if ~strcmpi(legendInterp, 'none')
    name = utils.plottools.label(str);
  else
    name = str;
  end  
end


function name = makeLegendStr(a, legendInterp, descOn)
  
  if ~strcmpi(legendInterp, 'none')
    name = utils.plottools.label(a.name);
    desc = utils.plottools.label(a.description);
  else
    name = a.name;
    desc = a.description;
  end
  
  if isempty(name)
    name = 'unknown';
  end
  
  if ~isempty(desc) && (LTPDAprefs.includeDescription || descOn)
    name = [name ': ' desc];
  end
  
  
end

% Perform some substitutions on the labels
function ss = fixlabel(ss)
  
  MAX_LENGTH = 100;
  wasCell = true;
  if ~iscell(ss)
    ss = {ss};
    wasCell = false;
  end
  
  for kk = 1:numel(ss)
    s = ss{kk};
    if ~isempty(s)
      % Replace all ^(...) with ^{...}
      jj = 1;
      while jj < numel(s)
        if strcmp(s(jj:jj+1), '^(')
          % find next )
          for k = 1:numel(s)-jj+1
            if s(jj+k) == ')'
              s(jj+1) = '{';
              s(jj+k) = '}';
              break;
            end
          end
        end
        jj = jj + 1;
      end
      % Replace all .^ with ^
      s = strrep(s, '.^', '^');
      
      % reduce size
      if length(s) > MAX_LENGTH
        addStr = '...';
      else
        addStr = '';
      end
      ssize = min(MAX_LENGTH, length(s));
      s = [s(1:ssize) addStr];
    end
    ss(kk) = {s};
  end
  
  
  if ~wasCell
    ss = ss{1};
  end
  
end



%----------------------------------------
% Prepare an axis label
function lstr = prepareAxisLabel(units, math, lstr, axis, UseLatex, a)
  if isa(units, 'unit')
    
    if ismac && UseLatex
      units = units.tolabel;
    else
      units = {fixlabel(char(units))};
    end
  else
    units = {units};
  end
  
  % try to get label from the data object.
  field = [axis 'axisname'];
  if ismethod(a.data, field)
    axisLabel = a.data.(field);
    if ~isempty(axisLabel) && ~any(strcmp(axisLabel, {'x', 'y', 'z'}))
      lstr = axisLabel;
    end
  end
  
  lstr = [fixlabel(lstr) '  ' units{1}];
end

% Parse cell-array of options
function opt = parseOptions(varargin) %jj, opts, dopt
  
  jj    = varargin{1};
  opts = varargin{2};
  dopt = varargin{3};
  opt   = dopt;
  
  if ~iscell(opts)
    opts = {opts};
  end
  Nopts = numel(opts);
  
  % First look for the 'all' keyword
  if Nopts == 2 && strcmpi(opts{1}, 'all')
    opt = opts{2};
  else
    if jj <= Nopts && ~isempty(opts{jj})
      opt = opts{jj};
    end
  end
  
end



% ERRORBARXY Customizable error bar plot in X and Y direction
%
% This function allows the user to plot the graph of x against y, along with
% both x and y errorbars.
%
% With 4 numeric arguments (x,y,dx,dy), error bar are assumed to be of
% same magnitude in both direction.
%
% One can specify lower and upper error bar with 6 numeric arguments
% (x,y,dx_high,dy_high,dx_low,dy_low).
%
% x,y,dx,dy,... must be vectors of the same length
%
% [hp he] = errorbarxy(...) returns respectively the handle for the line
% plot object and the line error bar object.
%
% It is possible to customize the line properties of the error bars by
% adding pair of 'field/value' fields (such as 'LineWidth',2) that can be
% understood by line. See LineProperties for more information.
%
% --------
% EXAMPLES
% --------
% X = 10 * rand(7,1);
% Y = 10 * rand(7,1);
% dx = rand(7,1);
% dy = rand(7,1);
% errorbarxy(X,Y,dx,dy,'Color','k','LineStyle','none','Marker','o',...
% 'MarkerFaceColor','w','LineWidth',1,'MarkerSize',11);
%
% X = 10 * rand(7,1);
% Y = 10 * rand(7,1);
% dx = rand(7,1);
% dy = rand(7,1);
% dx2 = rand(7,1);
% dy2 = rand(7,1);
% errorbarxy(X,Y,dx,dy,dx2,dy2,'Color','B','LineStyle','--','Marker','s',...
% 'MarkerFaceColor','w','LineWidth',2,'MarkerSize',11);
%
% This is a rewrite of the m-file errorbarxy of James Rooney, to add
% customizable line properties.

% ------------------ INFO ------------------
%   Authors: Jean-Yves Tinevez
%   Work address: Max-Plank Insitute for Cell Biology and Genetics,
%   Dresden,  Germany.
%   Email: tinevez AT mpi-cbg DOT de
%   November 2007 - June 2008;
%   Permission is given to distribute and modify this file as long as this
%   notice remains in it. Permission is also given to write to the author
%   for any suggestion, comment, modification or usage.
% ------------------ BEGIN CODE ------------------

function out = errorbarxy(ax, x,y,varargin)
  
  
  nargs = length(varargin);
  
  for i = 1 : nargs
    
    if ~( isnumeric(varargin{i}) )
      break
    end
    errbaropt{i} = varargin{i};
    
  end
  
  
  if i+3 < nargin
    displayopt = varargin(i:end);
    if isstruct(displayopt{1})
      options = displayopt{1};
    else
      options = varargin2struct(displayopt);
    end
    erroroptions = options;
  else
    displayopt = [];
  end
  
  options.Color = 'k';
  erroroptions.LineStyle = '-';
  erroroptions.Marker = 'none';
  
  
  xw = (max(x)-min(x))/100;
  yw = (max(y)-min(y))/100;
  
  n = length(varargin) - length(displayopt);
  
  if n == 2
    % only 2 cells, so this is the same for lower and upper bar
    ux = errbaropt{1};
    lx = ux;
    uy = errbaropt{2};
    ly = uy;
    
  elseif n == 4
    % 4 cells, the user specified both upper and lower limit
    ux = errbaropt{1};
    lx = errbaropt{3};
    uy = errbaropt{2};
    ly = errbaropt{4};
    
  else
    errid = 'MATLAB:errorbarxy:BadArgumentNumber';
    errmsg = ['Must have 4 or 6 numeric arguments, got ' ,num2str(n+2),'.'];
    error(errid,errmsg);
    
  end
  
  
  %%
  
  holdstate = ishold(gca);
  X = [];
  Y = [];
  for t = 1:length(x)
    
    % x errorbars
    X = [ X     nan x(t)-lx(t) x(t)+ux(t)    nan    x(t)-lx(t) x(t)-lx(t) nan     x(t)+ux(t) x(t)+ux(t)         ];
    Y = [ Y     nan y(t) y(t)                nan    y(t)-yw y(t)+yw       nan     y(t)-yw y(t)+yw               ];
    
    % y errorbars
    X = [ X     nan x(t) x(t)                nan    x(t)-xw x(t)+xw       nan     x(t)-xw x(t)+xw               ];
    Y = [ Y     nan y(t)-ly(t) y(t)+uy(t)    nan    y(t)-ly(t) y(t)-ly(t) nan     y(t)+uy(t) y(t)+uy(t)         ];
    
  end
  
  hold on
  axes(ax);
  he = line(X,Y,erroroptions);
  hp = plot(ax, x,y,options);
  out = [hp he];
  
  % Return to initial hold state if needed
  if ~holdstate
    hold off
  end
  
  function out = varargin2struct(in)
    % I hould write help
    
    if ~iscell(in)
      errid = 'MATLAB:struct2varargin:BadInputType';
      errmsg = ['Input argument must be a cell, got a ' ,class(in),'.'];
      error(errid,errmsg);
    end
    
    n = length(in);
    
    if mod(n,2) ~= 0
      errid = 'MATLAB:struct2varargin:BadInputType';
      errmsg = ['Input argument must have an even number of elements, got ' ,num2str(n),'.'];
      error(errid,errmsg);
    end
    
    out = struct;
    
    for jj = 1 : n/2
      name = in{2*jj-1};
      value = in{2*jj};
      out.(name) = value;
    end
    
  end
  
end

% Get a suitable ymin and ymax (in logscale) for the given
% data.
function [ticks,ymin,ymax] = getRealYDataTicks(y, ymin, ymax, complexPlotType, scale)
  
  ticks = [];
  switch complexPlotType
    case 'realimag'
      if strcmpi(scale', 'log')
        
        % do nothing because it doesn't make sense since we will have
        % negative values on a log scale
        
      end
    case {'absdeg', 'absrad'}
      
      if strcmpi(scale, 'log')
        % This is the main case we want to cover.
        ay = abs(y);
        newymin = min(ymin, floor(log10(min(ay(ay>0)))));
        newymax = max(ymax, ceil(log10(max(ay(ay>0)))));
        
        if ~isempty(newymin) && ~isempty(newymax)
          ymin = newymin;
          ymax = newymax;
          
          if ymin == ymax
            ymin = floor(log10(min(ay)/10));
            ymax = ceil(log10(max(ay)*10));
          end
          
        else
          
          if ymin == inf
            ymin = -1;
          end
          
          if ymax == -inf
            ymax = 1;
          end
          
        end
        nticks = ymax - ymin +1;
        % can we reduce this if they don't all fit?
        
        ticks = logspace(ymin, ymax, nticks);
      end
      
    otherwise
      error('### Unknown plot type for complex data');
  end
  
end

% Get a suitable ymin and ymax (in linscale) for the given
% data.
function ticks = getImagYDataTicks(y, ymin, ymax, complexPlotType, scale)
  
  
  ticks = [];
  switch complexPlotType
    case 'realimag'
      if strcmpi(scale', 'log')
        
        % do nothing because it doesn't make sense since we will have
        % negative values on a log scale
        
      end
    case 'absdeg'
      
      if strcmpi(scale', 'log')
        % do nothing because it doesn't make sense since we will have
        % negative values on a log scale
      end
      
    case 'absrad'
      
    otherwise
      error('### Unknown plot type for complex data');
  end
  
  
end

%-------------------
% Process errorbars
function [fcn, xu, xl, yu, yl] = process_errors(jj, dsize, ptype, XerrU, XerrL, YerrU, YerrL, a, autoErrs)
  
  if iscell(autoErrs)
    auto = autoErrs{jj};
  elseif islogical(autoErrs)
    auto = autoErrs;
  else
    auto = false;
  end
  
  if auto || (~isempty(a.plotinfo) && a.plotinfo.showErrors)
    showErrors = true;
  else
    showErrors = false;
  end
  
  if numel(XerrL) == 1
    xl = XerrL{1};
  else
    xl = XerrL{jj};
  end
  if numel(XerrU) == 1
    xu = XerrU{1};
  else
    xu = XerrU{jj};
  end
  if numel(YerrL) == 1
    yl = YerrL{1};
  else
    yl = YerrL{jj};
  end
  if numel(YerrU) == 1
    yu = YerrU{1};
  else
    yu = YerrU{jj};
  end
  
  % Check if we have AOs
  if isa(xl, 'ao'), xl = xl.data.getY; end
  if isa(xu, 'ao'), xu = xu.data.getY; end
  if isa(yl, 'ao'), yl = yl.data.getY; end
  if isa(yu, 'ao'), yu = yu.data.getY; end
  
  if isempty(xl) && ~isempty(xu)
    xl = xu;
  end
  if isempty(xu) && ~isempty(xl)
    xu = xl;
  end
  if isempty(yl) && ~isempty(yu)
    yl = yu;
  end
  if isempty(yu) && ~isempty(yl)
    yu = yl;
  end
  
  
  
  % If the AO has errors, we use them
  if ~isempty(a.dy) && showErrors
    yl = a.dy;
    yu = a.dy;
    yu(yu==inf) = 0;
    yl(yl==inf) = 0;
  end
  
  % If the AO has x errors, we use them
  if ~isempty(a.dx) && showErrors
    xl = a.dx;
    xu = a.dx;
    xu(xu==inf) = 0;
    xl(xl==inf) = 0;
  end
  
  if isempty(xl) && isempty(xu) && isempty(yu) && isempty(yl)
    fcn = ptype;
  elseif isempty(xl) && isempty(xu)
    fcn = 'errorbar';
  else
    fcn = 'errorbarxy';
  end
  
  if isempty(xl), xl = zeros(dsize); end
  if isempty(yl), yl = zeros(dsize); end
  if isempty(xu), xu = zeros(dsize); end
  if isempty(yu), yu = zeros(dsize); end
  if numel(xl) == 1, xl = xl.*ones(dsize); end
  if numel(xu) == 1, xu = xu.*ones(dsize); end
  if numel(yu) == 1, yu = yu.*ones(dsize); end
  if numel(yl) == 1, yl = yl.*ones(dsize); end
  
  yu = real(yu);
  yl = real(yl);
end

function applyPlotSettings(axesH, lineH)
  
  prefs = getappdata(0, 'LTPDApreferences');
  jPlotPrefs = prefs.getPlotPrefs();
  
  if jPlotPrefs.getPlotApplyPlotSettings.equals(mpipeline.ltpdapreferences.EnumPlotSetting.IPLOT_ONLY)
    
    % Set all axes properteis
    for ii =1:numel(axesH)
      safeset(axesH(ii), 'FontSize', double(jPlotPrefs.getPlotDefaultAxesFontSize));
      safeset(axesH(ii), 'LineWidth', double(jPlotPrefs.getPlotDefaultAxesLineWidth));
      safeset(axesH(ii), 'GridLineStyle', char(jPlotPrefs.getPlotDefaultAxesGridLineStyle));
      safeset(axesH(ii), 'MinorGridLineStyle', char(jPlotPrefs.getPlotDefaultAxesMinorGridLineStyle));
      switch char(jPlotPrefs.getPlotDefaultAxesFontWeight)
        case 'Plain'
          safeset(axesH(ii), 'FontWeight', 'normal');
        case 'Bold'
          safeset(axesH(ii), 'FontWeight', 'bold');
        case 'Italic'
          safeset(axesH(ii), 'FontWeight', 'light');
        case 'Bold Italic'
          safeset(axesH(ii), 'FontWeight', 'demi');
        otherwise
          error('### Unknown value (%s) for the default axes property ''FontWeight''', char(jPlotPrefs.getPlotDefaultAxesFontWeight));
      end
    end
  end
end

% Synchronize limits of the x-axes if the x-values are the same
function linkXaxes(ax)
  
  equal = true;
  % Get the x-values from the axes handle(s)
  for ii=2:numel(ax)
    
    x1 = get(get(ax(ii-1), 'children'), 'XData');
    x2 = get(get(ax(ii),   'children'), 'XData');
    x1 = reshape(x1, [], 1);
    x2 = reshape(x2, [], 1);
    
    if iscell(x1)
      % In this case contains the axes more lines
      if any(diff(cellfun(@numel, x1)))
        equal = false;
        break;
      else
        x1 = cell2mat(x1);
      end
    end
    if iscell(x2)
      % In this case contains the axes more lines
      if any(diff(cellfun(@numel, x2)))
        equal = false;
        break;
      else
        x2 = cell2mat(x2);
      end
    end
    
    % Compare x-values
    if ~utils.helper.eq2eps(x1, x2)
      equal = false;
      break;
    end
  end
  
  if equal
    linkaxes(ax,'x');
  end
  
end


% END
