% PLOT plots the given tfmap on the given axes
%
% CALL:
%         [lh, xlabel] = plot(data, ah)
%         [lh, xlabel] = plot(data, displayName, ah)
%

function lh = plot(varargin)
  
  switch nargin
    case 2
      data = varargin{1};
      pi   = varargin{2};
      displayName = 'unknown';
    case {3, 4}
      data        = varargin{1};
      displayName = varargin{2};
      pi          = varargin{3};
    otherwise
      error('Incorrect inputs');
  end
  
  % get axis handles
  ah = pi.axes;
  
  % prepare plotting function
  x = data.getX;
  y = data.getY;
  z = data.getZ;
    
  % plot data
  lh = pcolor(ah, x, y, z);
  
  % plot properties
  set(lh, 'EdgeColor', 'none');
  
  % set line display name
  set(lh, 'displayname', displayName);  
  
  % Set colorbars
  hc = colorbar('peer', ah);  
  ylh = ylabel(data.getZunits, hc, sprintf('Amplitude'));  
  set(ylh, 'Fontsize', get(ah, 'Fontsize'))
  set(ylh, 'FontName', get(ah, 'FontName'))
  set(ylh, 'FontAngle', get(ah, 'FontAngle'))
  set(ylh, 'FontWeight', get(ah, 'FontWeight'))
 
  % update axis labels
  xlabel(data.getXunits, ah, sprintf('Time since %s', char(data.t0)));
  ylabel(data.getYunits, ah, 'Value');
  
  % Reverse y-direction for spectrograms
  set(ah, 'YDir', 'reverse');
  
end


% END
