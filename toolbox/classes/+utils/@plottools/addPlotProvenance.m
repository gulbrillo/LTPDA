% ADDPLOTPROVENANCE adds a discrete text label to a figure with details of
% the LTPDA version, and the calling function from which the plot was made.
%
function addPlotProvenance(varargin)
  
  if nargin == 0
    fh = get(0, 'CurrentFigure');
  else
    fh = varargin{1};
  end
  
  if isempty(fh)
    error('Please provide a valid figure handle, or ensure there is a current figure.');
  end
  
  % message
  msg{1} = sprintf('LTPDA %s', getappdata(0, 'ltpda_version'));
  msg{end+1} = format(time());
  
  % check all inputs for additional strings
  for kk=1:nargin
    if ischar(varargin{kk})
      msg{end+1} = strrep(varargin{kk}, '_', '\_');
    end
  end
  
  % ensure the figure is current
  figure(fh);
  
  stack = dbstack('-completenames');
  
  if numel(stack) == 0
    % command line
    msg{end+1} = sprintf('plotted from command-line');
  else
    % top-level calling script
    msg{end+1} = strrep(stack(end).name, '_', '\_');
  end
  
  
  % check if an annotation object is already present
  annoString = 'LTPDA_ANNOTATION';
  hAxis = getAnnoObject(fh, annoString);
  
  if isempty(hAxis)
    
    hAxis = axes('units', 'normalized', 'pos', [0 0 1 .03], 'visible', 'off', 'handlevisibility', 'on');
    set(hAxis, 'Tag', annoString);
    th = text(0.5,1, utils.prog.strjoin(msg, ', '), 'parent', hAxis);
    set(th, 'Units', 'normalized');
    set(th, 'HorizontalAlignment', 'center');
    set(th, 'FontSize', 9);
    set(th, 'Color', [0.6 0.6 0.6]);
    set(th, 'Tag', annoString);
    set(th, 'UserData', varargin);
    uistack(hAxis,'bottom');
  else
    % set the text
    th = getAnnoObject(hAxis, annoString);
    userData = get(th, 'UserData');
    for kk=1:numel(userData)
      if ischar(userData{kk})
        s = strrep(userData{kk}, '_', '\_');
        if ~any(strcmp(s, msg))
          msg{end+1} = s;
        end
      end
    end
    set(th, 'UserData', varargin);
    set(th, 'String', utils.prog.strjoin(msg, ', '));
    uistack(hAxis,'bottom');
  end
  
end

function h = getAnnoObject(fh, annoString)
  
  h = [];
  children = get(fh, 'children');
  for kk=1:numel(children)
    tag = get(children(kk), 'Tag');
    if strcmp(tag, annoString)
      h = children(kk);
      break;
    end
  end
  
  
end
