% PLOT plots the given fsdata on the given axes
%
% CALL:
%         lh = plot(data, ah)
%         lh = plot(data, displayName, ah)
%         lh = plot(data, displayName, ah, fcn)
%
%
function lh = plot(varargin)
  
  switch nargin
    case 2
      data = varargin{1};
      pi   = varargin{2};
      displayName = 'unknown';
      fcn         = 'plot';
    case 3
      data        = varargin{1};
      displayName = varargin{2};
      pi          = varargin{3};
      fcn         = 'plot';
    case 4
      data        = varargin{1};
      displayName = varargin{2};
      pi          = varargin{3};
      fcn         = varargin{4};    
    otherwise
      error('Incorrect inputs');
  end
  
  % get axis handles
  ah = pi.axes;
        
  % prepare plotting function
  [f, x, y] = prepareForPlotting(data, pi.showErrors, fcn);  
  
  if ~isreal(y) && numel(ah) == 1
    
    % plot data
    y = abs(y);
    lh = f(ah, x, y);
    for kk=2:numel(lh)
      set(get(get(lh(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
    end
    
    % set axis scales
    set(ah, 'Xscale', 'log');
    set(ah, 'Yscale', 'log');
    
    % set line display name
    set(lh, 'displayname', sprintf('abs(%s)', displayName));
    
    % update axis labels
    xlabel(data.xunits, ah, 'Frequency');
    ylabel(data.yunits, ah, 'Value');
    
  elseif ~isreal(y) && numel(ah) == 2
    
    % plot data
    lh(1) = f(ah(1), x, abs(y));
    lh(2) = f(ah(2), x, utils.math.phase(y));
    for kk=3:numel(lh)
      set(get(get(lh(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
    end
    
    % set axis scales
    set(ah(1), 'Xscale', 'log');
    set(ah(2), 'Xscale', 'log');
    set(ah(1), 'Yscale', 'log');
    
    % set line display name
    set(lh(1), 'displayname', sprintf('ABS(%s)', displayName));
    set(lh(2), 'displayname', sprintf('Phase(%s)', displayName));
    
    % update axis labels
    xlabel(data.xunits, ah, 'Frequency');
    ylabel(data.yunits, ah(1), 'Value');
    ylabel(unit('deg'), ah(2), 'Value');
    
  else
    % plot data
    lh = f(ah, x, y);
    for kk=2:numel(lh)
      set(get(get(lh(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
    end
    
    % set axis scales
    set(ah, 'Xscale', 'log');
    set(ah, 'Yscale', 'log');
    
    % set line display name
    set(lh, 'displayname', displayName);
    
    % update axis labels
    xlabel(data.xunits, ah, 'Frequency');
    ylabel(data.yunits, ah, 'Value');
  end

  
end

