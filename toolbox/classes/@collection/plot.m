% PLOT the collection objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT the collection objects axes.
%
% CALL:        plot(c)
%              plot(c1, c2);
%
% PLOT will produce one figure per collection. For a given collection, each element
% of the collection is plotted on the same set of axes.
%
% Collections of collection or matrix objects are not supported.
%
% NOTE: the 'axes' and 'figure' properties of the plotinfo of any contained
% user objects are ignored in the process.
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'plot')">Parameters Description</a>
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
  [colls, mat_invars] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(colls, 1);
  
  
  % loop over collections
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
        obj.plotinfo.figure = figure();
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
    
    % check axes
    if isempty(obj.plotinfo) || isempty(obj.plotinfo.axes)
      figure();
      ax = axes();
    else
      ax = obj.plotinfo.axes;
    end
    
    % reset plot styles
    plotinfo.resetStyles();
    
    % plot collection
    plotCollection(obj, ax);
    
    % Replace the UserData of the figure handle with this matrix object.
    utils.plottools.cacheObjectInUserData(obj.plotinfo.figure, obj, 'replace');
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

function plotCollection(coll, ax)
  
  % collection requirements
  collReqs = coll.requirements(plist('hashes', true));
  
  % plot the elements
  for rr=1:numel(coll.objs)
    plotElement(coll.objs{rr}, ax, collReqs);
  end
  
end

function plotElement(obj, ax, collReqs)
  
  fprintf('Plotting [%s]\n', obj.name)
  
  obj.setPlotAxes(ax);
  
  obj.plot(plist('additional requirements', collReqs));
  
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
  pl = plist.EMPTY_PLIST;
end

% END


