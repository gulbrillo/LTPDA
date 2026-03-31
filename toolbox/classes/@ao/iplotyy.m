% IPLOTYY provides an intelligent plotting tool for LTPDA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IPLOTYY provides an intelligent plotting tool for LTPDA.
%
% CALL:               hfig = iplotyy (a1,a2,pl)
%              [hfig, hax] = iplotyy (a1,a2,pl)
%         [hfig, hax, hli] = iplotyy (a1,a2,pl)
%
% INPUTS:      pl  - a parameter list
%              a1  - input analysis object for left y-axis
%              a2  - input analysis object for right y-axis
%
% NOTE: the two input AOs must be the same data type.
%
% OUTPUTS:     hfig - handles to figures
%              hax  - handles to axes
%              hli  - handles to lines
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'iplotyy')">Parameters Description</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = iplotyy(varargin)
  
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
  
  % Check inputs
  if nargin ~= 2 && nargin ~= 3
    error('### Incorrect inputs');
  end
  
  % Collect arrays
  if nargin >= 2
    leftAOs = copy(varargin{1});
    rightAOs = copy(varargin{2});
  end
  if ~isa(leftAOs, 'ao') || ~isa(rightAOs, 'ao')
    error('### Please input two AOs followed by plists');
  end
  
  % get data type of a1
  dtype1 = class([leftAOs.data]);
  % get data type of a2
  dtype2 = class([rightAOs.data]);
  
  % check two arrays
  if ~strcmp(dtype1, dtype2)
    error('### The two input AOs should contain the same data type.');
  end
  
  dtype = dtype1;
  
  % Collect plists
  switch dtype
    case 'tsdata'
      dpl = getDefaultPlist('time-series plot');
      
      % ensure we have the same time reference
      t0 = leftAOs(1).t0;
      leftAOs.setReferenceTime(t0);
      rightAOs.setReferenceTime(t0);
      
    case 'fsdata'
      dpl = getDefaultPlist('frequency-series plot');
    case 'xydata'
      dpl = getDefaultPlist('x-y plot');
    case 'cdata'
      dpl = getDefaultPlist('y plot');
    otherwise
      error('AOs are of unsupported data type [%s]', dtype);
  end
  
  if nargin >= 3
    pl = applyDefaults(dpl, varargin{3:end});
  else
    pl = copy(dpl,1);
  end
  
  % preferences
  leftYScale  = pl.find_core('LeftYScale');
  rightYScale = pl.find_core('RightYScale');
  xScale      = pl.find_core('XScale');
  lylabels    = pl.find_core('LeftYLabels');
  rylabels    = pl.find_core('RightYLabels');
  % Use latex?
  UseLatex = pl.find_core('LatexLabels');
  if ischar(UseLatex)
    UseLatex = eval(UseLatex);
  end
  
  % prepare axes
  fh = pl.find('figure');
  if ~isempty(fh) && ishandle(fh)
    hfig = figure(fh);
  else
    hfig = figure();
  end
  
  % Use MATLAB's plotyy because it does the right job of laying out the y
  % axes so that the grid lines overlay properly. I couldn't find a way to
  % do that easily myself. Here I choose the first of the left and right
  % objects to set the scale. Not sure how to do that better.
  
  if strcmpi(leftYScale, 'lin')
    if strcmpi(xScale, 'lin')
      leftFunc = 'plot';
    else
      leftFunc = 'semilogx';
    end
  else
    if strcmpi(xScale, 'lin')
      leftFunc = 'semilogy';
    else
      leftFunc = 'loglog';
    end
  end
  
  if strcmpi(rightYScale, 'lin')
    if strcmpi(xScale, 'lin')
      rightFunc = 'plot';
    else
      rightFunc = 'semilogx';
    end
  else
    if strcmpi(xScale, 'lin')
      rightFunc = 'semilogy';
    else
      rightFunc = 'loglog';
    end
  end
  
  ax = plotyy(leftAOs(1).x, leftAOs(1).y, rightAOs(1).x, rightAOs(1).y, leftFunc, rightFunc);
  
  % process left y range
  leftyrange = pl.find_core('leftyrange');
  if ~isempty(leftyrange)
    ylim(ax(1), leftyrange);
    set(ax(1), 'YTickMode', 'auto');
  end
  
  % process rigtht y range
  rightyrange = pl.find_core('rightyrange');
  if ~isempty(rightyrange)
    ylim(ax(2), rightyrange);
    set(ax(2), 'YTickMode', 'auto');
  end
  
  leftYlim   = get(ax(1), 'Ylim');
  rightYlim   = get(ax(2), 'Ylim');
  leftYticks = get(ax(1), 'Ytick');
  rightYticks = get(ax(2), 'Ytick');
  xLim   = get(ax(1), 'Xlim');
  xTicks = get(ax(1), 'Xtick');
  delete(ax);
  
  ax(1) = newplot();
  ax(2) = axes('Parent', get(ax(1), 'Parent'));
  
  set(ax(1), 'yaxislocation', 'left');
  set(ax(1), 'ycolor', 'black');
  
  set(ax(2), 'ycolor', 'red');
  set(ax(2), 'yaxislocation', 'right');
  set(ax(2), 'color', 'none');
  
  plotinfo.resetStyles;
  for kk=1:numel(leftAOs)
    leftAOs(kk).setPlotAxes(ax(1));
  end
  
  for kk=1:numel(rightAOs)
    rightAOs(kk).setPlotAxes(ax(2)); 
  end
  
  ppl = pl.subset(ao.getInfo('plot').plists.getKeys);
  plot(leftAOs, ppl);
  plot(rightAOs, ppl);
  
  % Set a new data data cursor mode for AO with tsdata
  if strcmp(dtype, 'tsdata')
    linkaxes(ax, 'x');
    set(ax(1), 'UserData', leftAOs.t0)
    set(ax(2), 'UserData', rightAOs.t0)
    dcmObj = datacursormode(hfig);
    set(dcmObj, 'UpdateFcn', @utils.plottools.datacursormode);
  end
  
  % Make sure that we get the cursor data tip for both axes
  set(ax(1), 'Hittest', 'on');
  set(ax(2), 'Hittest', 'off');
  
  % deal with legends
  legend(ax(1), 'off');
  leftLegend = legend(ax(1), 'show');
  legend(ax(2), 'off');
  rightLegend = legend(ax(2), 'show');
  
  set(leftLegend, 'EdgeColor', 'k')
  set(rightLegend, 'EdgeColor', 'r')
  set(leftLegend, 'location', 'NorthWest');
  
  % Now fix the ticks and ranges back to what MATLAB's plotyy computed for us
  set(ax(1), 'YTick', leftYticks);
  set(ax(2), 'YTick', rightYticks);
  set(ax(1), 'Ylim', leftYlim);
  set(ax(2), 'Ylim', rightYlim);
  set(ax(1), 'Xlim', xLim);
  set(ax(2), 'Xlim', xLim);
  set(ax(1), 'Xtick', xTicks);
  set(ax(2), 'Xtick', xTicks);
  
  % Set ylabels
  if ~isempty(lylabels)
    ylabel(leftAOs(1).yunits, ax(1), lylabels);
  end
  if ~isempty(rylabels)
    ylabel(rightAOs(1).yunits, ax(2), rylabels);
  end
  
  % Latex labels
  if UseLatex
    set(ax(1).YLabel, 'interpreter', 'latex');
    set(ax(2).YLabel, 'interpreter', 'latex');
  end
  
  % Setup x-axis
  xrange = pl.find_core('xrange');
  if ~isempty(xrange)
    utils.plottools.xlim(ax, xrange);
  else
    % Set the x limits to a range that covers all the data on both axes
    leftXlim = get(ax(1), 'Xlim');
    rightXlim = get(ax(2), 'Xlim');
    set(ax(1), 'Xlim', [min(leftXlim(1), rightXlim(1)) max(leftXlim(2), rightXlim(2))]);
    set(ax(2), 'Xlim', [min(leftXlim(1), rightXlim(1)) max(leftXlim(2), rightXlim(2))]);
  end
  set(ax(2), 'Xtick', []);
  xlabel(ax(2), '');
  linkaxes(ax, 'x');
  
  % Add the grid lines
  grid(ax(2), 'off');
  box(ax(1), 'on');
  box(ax(2), 'off');
  
  
  % process left y scale
  if ~isempty(leftYScale)
    set(ax(1), 'yscale', leftYScale);
  end
  
  % process right y scale
  if ~isempty(rightYScale)
    set(ax(2), 'yscale', rightYScale);
  end
  
  % process x scale
  if ~isempty(xScale)
    set(ax(1), 'xscale', xScale);
    set(ax(2), 'xscale', xScale);
  end
  
  
  % Add provenance to each figure
  if pl.find_core('show provenance')
    reqs = requirements(leftAOs, rightAOs, plist('hashes', true));
    for jj=1:numel(hfig)
      utils.plottools.addPlotProvenance(hfig(jj), reqs{:});
    end
  end
  
  % select the data axes again
  axes(ax(end));
  for ff=1:numel(hfig)
    chs = get(hfig(ff), 'children');
    for kk=1:numel(chs)
      tag = get(chs(kk), 'tag');
      if strcmpi(tag, 'legend')
        uistack(chs(kk), 'top');
      end
    end
  end
  
  % Set title if the user provides one
  if ~isempty(pl.find('Title'))
    title(pl.find('Title'));
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
  
  % Deal with outputs
  if nargout == 1
    varargout{1} = hfig;
  end
  if nargout == 2
    varargout{1} = hfig;
    varargout{2} = ax;
  end
  if nargout == 3
    varargout{1} = hfig;
    varargout{2} = ax;
    varargout{3} = hli;
  end
  
  if nargout > 3
    error('### Incorrect number of outputs');
  end
  
end

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
    sets = {'Time-series Plot', 'Frequency-series Plot', 'Y Plot', 'X-Y Plot'};
    % get plists
    pl(size(sets)) = plist;
    for k = 1:numel(sets)
      pl(k) =  getDefaultPlist(sets{k});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
  ii.setOutmin(0);
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

function out = buildplist(varargin)
  
  set = '';
  if nargin == 1
    set = varargin{1};
  end
  
  out = plist();
  
  % include plot options
  out.append(copy(ao.getInfo('plot').plists));
  
  % plot fcn - override because I don't know how to do bar plots yy
  out.remove('fcn');
  p = param({'fcn', 'The plot function to use. Note: if errors are plotted, then this value is ignored.'}, {1, {'plot', 'stairs', 'stem'}, paramValue.SINGLE});
  out.append(p);
  
  % XRanges
  p = param({'XRange', ['A 2-element array specifying the ranges to be displayed on the x-axis.<br>']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % LeftYRanges
  p = param({'LeftYRange', ['A 2-element array specifying the range to be displayed on the left y-axis.']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % RightYRanges
  p = param({'RightYRange', ['A 2-element array specifying the range to be displayed on the right y-axis.']}, {1, {''}, paramValue.OPTIONAL});
  out.append(p);
  
  % FigureNames
  p = param({'FigureNames','Sets the figure name.'}, paramValue.EMPTY_STRING);
  out.append(p);
  
  % Figure
  p = param({'figure', 'The handle of the figure to plot in to.'}, paramValue.EMPTY_DOUBLE);
  out.append(p);
  
  % Titles
  p = param({'Title', 'A string specifying the title.'}, paramValue.EMPTY_STRING);
  out.append(p);
  
  % Ylabels
  p = param({'LeftYLabels',['Specify the labels to be used on the left y-axes. The units are added from<br>',...
    'the data object ''yunits'' property.']}, paramValue.STRING_VALUE('Amplitude'));
  out.append(p);
  
  p = param({'RightYLabels',['Specify the labels to be used on the right y-axes. The units are added from<br>',...
    'the data object ''yunits'' property.']}, paramValue.STRING_VALUE('Amplitude'));
  out.append(p);
  
  % LatexLabels
  p = param({'LatexLabels','Use latex interpreter for axis labels.'}, paramValue.FALSE_TRUE);
  out.append(p);
  
  switch lower(set)
    case 'frequency-series plot'
      out.append(...
        'LeftYScale', 'log', ...
        'RightYScale', 'log', ...
        'XScale', 'log');
    case 'time-series plot'
      out.append(...
        'LeftYScale', 'lin', ...
        'RightYScale', 'lin', ...
        'XScale', 'lin');
    case 'x-y plot'
      out.append(...
        'LeftYScale', 'lin', ...
        'RightYScale', 'lin', ...
        'XScale', 'lin');
    case 'y plot'
    otherwise
      error('### Unknown set [%s]', set);
  end
end
