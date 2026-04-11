% PLOT plots the given cdata on the given axes
%
% CALL:
%         lh = plot(data, ah)
%         lh = plot(data, displayName, ah)
%         lh = plot(data, displayName, ah, plotfcn)
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
  
  xstr = 'Sample [Index]';
  
  % prepare data
  [f, y] = prepareForPlotting(data, pi.showErrors, fcn);
  
  % check the type of data
  if ~isreal(y) && numel(ah) == 1
    
    % plot data
    y = abs(y);
    lh = f(ah, y);
    
    % update axis labels
    xlabel(ah, xstr);
    
    % set line display name
    set(lh, 'displayname', sprintf('abs(%s)', displayName));
    
  elseif ~isreal(y) && numel(ah) == 2
    
    % plot data
    lh(1) = f(ah(1), real(y));
    lh(2) = f(ah(2), imag(y));
    
    % set line display name
    set(lh(1), 'displayname', sprintf('REAL(%s)', displayName));
    set(lh(2), 'displayname', sprintf('IMAG(%s)', displayName));
    
  else
    % plot data
    lh = f(ah, y);
        
    % set line display name
    set(lh, 'displayname', displayName);
  end
  
  % update axis labels
  xlabel(unit('Index'), ah, 'Sample');
  ylabel(data.yunits, ah, 'Value');
  
  
end
