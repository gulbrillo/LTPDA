% BACKUPDEFAULTPLOTSETTINGS Backup the current default plot settings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BACKUPDEFAULTPLOTSETTINGS Backup the current default plot
%              settings. This method will store the current setting in the
%              application data 'defaultPlotSettings'.
%
% CALL:        backupDefaultPlotSettings()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function backupDefaultPlotSettings()
  
  defaultPlotSettings.DefaultAxesFontSize           = get(0, 'DefaultAxesFontSize');
  defaultPlotSettings.DefaultAxesLineWidth          = get(0, 'DefaultAxesLineWidth');
  defaultPlotSettings.DefaultAxesGridLineStyle      = get(0, 'DefaultAxesGridLineStyle');
  defaultPlotSettings.DefaultAxesMinorGridLineStyle = get(0, 'DefaultAxesMinorGridLineStyle');
  defaultPlotSettings.DefaultAxesFontWeight         = get(0, 'DefaultAxesFontWeight');
  setappdata(0, 'defaultPlotSettings', defaultPlotSettings);
  
end
