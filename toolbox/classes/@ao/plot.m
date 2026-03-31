% PLOT the analysis objects on the given axes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT the analysis objects on the given axes.
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
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'plot')">Parameters Description</a>
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
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % input plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Decide on a deep copy or a modify
  bs = copy(as, 1);
  
  % additional requirements
  addReqs = cellstr(pl.find_core('additional requirements'));
  
  % show provenance
  showProvenance = pl.find_core('show provenance');
  
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
        if isempty(lastObj) || ~isa(lastObj.data, class(obj.data))
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
    
    % plot the object
    plotObject(obj, pl.find_core('fcn'));
        
    % annotate figure
    if showProvenance
      reqs = unique([addReqs obj.requirements(plist('hashes', true))]);
      utils.plottools.addPlotProvenance(obj.plotinfo.figure, reqs{:});
    end
    
    % Store this object
    lastObj = obj;
  end
  
  % select the data axes again
  axes(lastObj.plotinfo.axes(end));
  chs = get(lastObj.plotinfo.figure, 'children');
  for kk=1:numel(chs)
    tag = get(chs(kk), 'tag');
    if strcmpi(tag, 'legend')
      uistack(chs(kk), 'top');
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end


% plot the given object
function plotObject(obj, fcn)
  
  import utils.const.*
  utils.helper.msg(msg.PROC1, 'plotting [%s] on %f...', obj.name, double(obj.plotinfo.axes));
  
  % ensure we have the correct figure selected
  figure(obj.plotinfo.figure);
    
  % plot data line
  obj.plotinfo.line = plot(obj.data, obj.legendString, obj.plotinfo, fcn);
  
  % set marker size
  prefs = getappdata(0, 'LTPDApreferences');
  jPlotPrefs = prefs.getPlotPrefs();
  
  % set line properties
  obj.plotinfo.applyLineStyle();  
    
  % update legend
  legendFontSize = double(jPlotPrefs.getPlotDefaultLegendFontSize);
  for kk=1:numel(obj.plotinfo.axes)
    legend(obj.plotinfo.axes(kk), 'off');
    legh = legend(obj.plotinfo.axes(kk), 'show');
    set(legh, 'FontSize', legendFontSize);
  end
    
  % cache object
  utils.plottools.cacheObjectInUserData(obj.plotinfo.figure, obj);
  
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
  
  % plot fcn
  p = param({'fcn', 'The plot function to use. Note: if errors are plotted, then this value is ignored.'}, {1, {'plot', 'stairs', 'bar', 'stem'}, paramValue.SINGLE});
  pl.append(p);
  
  % include provenance patch
  p = param({'show provenance', 'A flag to enable/disable the provenance text patch.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  
  % additional requirements
  p = param({'additional requirements', 'Specify any additional requirements needed to produce the data in the plot.'}, paramValue.EMPTY_CELL);
  pl.append(p);
end

% END


