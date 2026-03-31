% PLOT plots the given xydata on the given axes
%
% CALL:
%         lh = plot(data, ah)
%         lh = plot(data, displayName, ah)
%         lh = plot(data, displayName, ah, plotfcn)
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
    
    % set line display name
    set(lh, 'displayname', sprintf('abs(%s)', displayName));
    
  elseif ~isreal(y) && numel(ah) == 2
    
    % plot data
    lh(1) = f(ah(1), x, real(y));
    lh(2) = f(ah(2), x, imag(y));
    
    % set line display name
    set(lh(1), 'displayname', sprintf('REAL(%s)', displayName));
    set(lh(2), 'displayname', sprintf('IMAG(%s)', displayName));
    
  else
    % plot data
    lh = f(ah, x, y);
    
    % set line display name
    set(lh, 'displayname', displayName);
  end
  
  for kk=2:numel(lh)
    set(get(get(lh(kk),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
  end
  
  % update axis labels
  xname = data.xaxisname;
  yname = data.yaxisname;
  if isempty(xname)
    xname = 'x';
  end
  if isempty(yname)
    yname = 'y';
  end
    
  xlabel(data.xunits, ah, xname);
  ylabel(data.yunits, ah, yname);
  
  
end
