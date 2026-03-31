% SETAPPLICATIONDATA sets the application data from the preferences object.
%
% Call:         LTPDAprefs.setApplicationData()
%
% Parameters:
%       prefs - preferences object
%

function setApplicationData()
  
  set(0,'DefaultAxesFontSize', LTPDAprefs.axesFontSize);
  set(0,'DefaultAxesLineWidth', LTPDAprefs.axesLineWidth);
  set(0,'DefaultAxesGridLineStyle', LTPDAprefs.gridStyle);
  set(0,'DefaultAxesMinorGridLineStyle', LTPDAprefs.minorGridStyle);
  val = LTPDAprefs.axesFontWeight;
  if strcmpi(val, 'Plain')
    set(0, 'DefaultAxesFontWeight', 'normal');
  elseif strcmpi(val, 'Bold')
    set(0, 'DefaultAxesFontWeight', 'bold');
  elseif strcmpi(val, 'Italic')
    set(0, 'DefaultAxesFontWeight', 'light');
  elseif strcmpi(val, 'Bold Italic')
    set(0, 'DefaultAxesFontWeight', 'demi');
  else
    error('### Unknown value (%s) for the default axes property ''FontWeight''', char(val));
  end
  
end
