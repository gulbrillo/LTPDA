% PLOT the timespan objects on the given axes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT the timespan objects on the given axes.
%
% CALL:        plot(objs)
%              outputs = plot(objs)
%
% PLOT checks each object's plotinfo for details about the figure and axes
% handle to plot the object on. The following rules are followed:
%
% 1) If the object's plotinfo is empty, a new figure and set of axes is
%    created and the object is plotted with the next available plot style.
%
% Assuming the object has a plotinfo:
%
% 2) If the plotinfo figure handle is empty, a new figure is created.
% 3) If the plotinfo axes handle is empty, a new set of axes is created.
%
% The output objects will contain the plotinfo that is used/created.
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'plot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plot(varargin)
  
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
  
  % Collect all timespans
  [ts, ao_invars] = utils.helper.collect_objects(varargin(:), 'timespan', in_names);
  
  % input plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Decide on a deep copy or a modify
  bs = copy(ts, 1);
  
  % plot filled boxes?
  filledBoxes = pl.find('filled');
  
  % determine absolute x-offset
  toffset = min(double(bs.startT));
  
  % plot each object
  lastObj = [];
  for kk=1:numel(bs)
    
    % this object
    obj = bs(kk);
    
    % if we have no plotinfo, make one
    if isempty(obj.plotinfo)
      obj.plotinfo = plotinfo();
    end
    
    % Check figure handle. If it's empty and the axes handle is empty, we
    % create a new figure. However, if the last object is of the same data
    % type, we use it's figure.
    if isempty(obj.plotinfo.figure) || ~ishghandle(obj.plotinfo.figure)
      if isempty(obj.plotinfo.axes) || ~all(ishghandle(obj.plotinfo.axes))
        if isempty(lastObj)
          obj.plotinfo.figure = figure();
        else
          obj.plotinfo.figure = lastObj.plotinfo.figure;
        end
      else
        % get the figure which is the parent of the first axes
        obj.plotinfo.figure = get(obj.plotinfo.axes(1), 'Parent');
      end
    end
    
    % make sure the figure exists
    figure(obj.plotinfo.figure);
        
    % Check axes handle. If it's empty we create a new set of axes.
    if isempty(obj.plotinfo.axes) || ~all(ishghandle(obj.plotinfo.axes))
      % check if the figure has some axes already
      currentAxes = utils.plottools.getAxes(obj.plotinfo.figure);
      if isempty(currentAxes)
        obj.plotinfo.axes = axes();
      else
        % use the first one
        obj.plotinfo.axes = currentAxes(1);
      end
    end
    
    % make sure the axes are hold on
    utils.plottools.hold(obj.plotinfo.axes, 'on');
    
    % switch on the grids
    set(obj.plotinfo.axes, 'XGrid', 'on');
    set(obj.plotinfo.axes, 'YGrid', 'on');
    set(obj.plotinfo.axes, 'XMinorGrid', 'on');
    set(obj.plotinfo.axes, 'YMinorGrid', 'on');
    
    % box on 
    utils.plottools.box(obj.plotinfo.axes, 'on');
    
    % get ymin/ymax from figure axes
    ylim = get(obj.plotinfo.axes, 'YLim');
    
    % plot the object
    plotObject(obj, pl.find_core('xunits'), toffset, filledBoxes, ylim);
        
    % Store this object
    lastObj = obj;
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end


% plot the given object
function plotObject(obj, xunits, toffset, filledBoxes, ylim)
  
  fprintf([sprintf('plotting %s on ', obj.name) sprintf('%f ', double(obj.plotinfo.axes)) sprintf('...\n')]);
  
  % ensure we have the correct figure selected
  figure(obj.plotinfo.figure);
  axh = obj.plotinfo.axes;
    
  % xunits
  switch xunits
    case 's'
      factor = 1;
    case 'm'
      factor = 60;
    case 'h'
      factor = 3600;
    case 'd'
      factor = 86400;
    case 'time'
      error('code me up');
    otherwise
      error('Unknown time scale [%s]', xunits);
  end
  
  % determine x position and y position
  height = 1.0;
  x(1) = double(obj.startT);
  len  = obj.nsecs;
  x(2) = x(1) + len;
  x(3) = x(2);
  x(4) = x(1);
  
  x = x - toffset;
  
  % scale
  x = x / factor;
  
  % check if there is another child within this area
  offset = 0;
  ymin = ylim(1);
  ymax = ylim(2);
  y = offset + [ymin ymin ymax ymax];
  if filledBoxes
    while patchWillOverlap(x, y, axh)
      offset = offset + 1;
      y = offset + [ymin ymin ymax ymax];
    end
  end
  
  % create patch
  axes(axh);
  ph = patch(x, y, obj.plotinfo.style.getMATLABColor');
  
  if filledBoxes
    set(ph, 'FaceAlpha', 1);
  else
    set(ph, 'FaceAlpha', 0);
  end
  set(ph, 'Edgecolor', obj.plotinfo.style.getMATLABColor, 'LineWidth', 4);
  
  % create label
  if isempty(obj.name)
    lbl = 'unknown';
  else
    lbl = strrep(obj.name, '_', '\_');
  end
  
  if ~isempty(obj.description)
    lbl = sprintf('%s\n%s', lbl, utils.prog.cutString(obj.description, 75));
  end
  
  th = text((x(2)+x(1))/2, (y(2)+y(3))/2, lbl);
  
  set(th, 'HorizontalAlignment','center',... 
       'BackgroundColor', obj.plotinfo.style.getMATLABColor, ...
       'Color', 'w', ...
       'rotation', -90);
  
  set(axh, 'YTickLabel', []);
  set(axh, 'YMinorGrid', 'off');
    
  xlabel(axh, sprintf('Time since %s [%s]', char(time(toffset)), xunits));
    
end

function overlap = patchWillOverlap(x, y, ah)
  
  
  chs = get(ah, 'children');
  overlap = false;
  for jj=1:numel(chs)
    ch = chs(jj);
    if strcmpi(get(ch, 'type'), 'patch')
      xdata = get(ch, 'XData');
      ydata = get(ch, 'YData');      
      overlap = overlaps(x, y, xdata, ydata);
      if overlap
        return
      end      
    end
  end
  
end

function overlap = overlaps(x1, y1, x2, y2)
   
  ax(1) = x1(1);
  ax(2) = x1(3);
  ay(1) = y1(1);
  ay(2) = y1(3);
  bx(1) = x2(1);
  bx(2) = x2(3);
  by(1) = y2(1);
  by(2) = y2(3);
  
  axr = abs(diff(ax)); % length of the rectangle's sides.
  ayr = abs(diff(ay));
  bxr = abs(diff(bx));
  byr = abs(diff(by));
  xr = axr+bxr; % minumum distance for them to not overlap
  yr = ayr+byr;
  xvct = [bx,ax]; % vectors of coords.
  yvct = [by,ay];
  outerdiffx = max(xvct)-min(xvct);
  outerdiffy = max(yvct)-min(yvct);
  
  overlap = outerdiffx<xr && outerdiffy<yr;

  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % plot with these units
  p = param({'xunits', 'The units to use on the x axis.'}, {1, {'s', 'm', 'h', 'd', 'time'}, paramValue.SINGLE});
  pl.append(p);
  
  % plot with filled boxes
  p = param({'filled', 'Fill the patches which mark the time-spans'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end

% END


