% PLOT the matrix objects on the given axes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT the analysis objects on the given axes.
%
% CALL:        plot(m)
%              plot(m1, m2);
%
% PLOT will produce one figure per matrix. For a given matrix, each element
% of the matrix is plotted on a subplot. If the element of a matrix is
% itself a matrix, then that sub-area of the plot is replaced with subplots
% for the contents of the inner matrix, etc.
%
% NOTE: the 'axes' and 'figure' properties of the plotinfo of any contained
% user objects are ignored in the process.
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'plot')">Parameters Description</a>
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
  [mats, mat_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(mats, 1);
  
  for kk=1:numel(bs)
    
    % this object
    obj = bs(kk);
    
    % if we have no plotinfo, make one
    if isempty(obj.plotinfo)
      obj.plotinfo = plotinfo();
    end
    
    % Check figure handle. If it's empty and the axes handle is empty, we
    % create a new figure.
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
    
    % plot area
    area = [0 0 1 1];

    % plot matrix
    plotMatrix(obj, area, obj.plotinfo.figure);
        
    % Store this object
    lastObj = obj;
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

function plotMatrix(mat, area, hfig)
  
  % reset plot styles.
  plotinfo.resetStyles();
  
  % Size of matrix
  s = size(mat.objs);
  
  % Number of rows, cols
  nrows = s(1);
  ncols = s(2);
  
  % matrix requirements
  matReqs = mat.requirements(plist('hashes', true));
  
  % plot the elements
  for rr=1:nrows
    for cc=1:ncols
      plotElement(mat.objs(rr, cc), nrows, ncols, rr, cc, hfig, area, matReqs);
    end
  end
  
  % Replace the UserData of the figure handle with this matrix object.
  utils.plottools.cacheObjectInUserData(hfig, mat, 'replace');
  
end

function plotElement(obj, nrows, ncols, row, col, hfig, area, matReqs)
  
  fprintf('Plotting [%s]\n', obj.name)
  
  xinset = 0.075;
  yinset = 0.12;
  
  % define the subplot area
  elementWidth  = (area(3) / ncols);
  elementHeight = (area(4) / nrows);
  
  % get offset
  xoffset = (col-1) * elementWidth;
  yoffset = area(4) - row * elementHeight;
  
  subplotArea = [xinset+xoffset yoffset+yinset elementWidth-1.5*xinset elementHeight-1.5*yinset];
  
  if isa(obj, 'matrix')
    
    % call plot again but set the plist
    plotMatrix(obj, subplotArea, hfig);
  
  elseif isa(obj, 'ltpda_uoh')
    
    % grab figure
    figure(hfig);
    
    % create subplot 
    axh = subplot('position', subplotArea);
    
    % set object's plotinfo
    obj.setPlotAxes(axh);
    
    % plot object
    obj.plot(plist('additional requirements', matReqs));
    
  else
    error('Don''t know how to plot objects of class %s', class(obj));
  end
  
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


