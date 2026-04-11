% RESTOREDEFAULTPLOTSETTINGS Restore the saved plot settings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESTOREDEFAULTPLOTSETTINGS Restore the saved plot settings.
%              This method will recover the saved plot settings which are
%              stored in the application data 'defaultPlotSettings'.
%
% CALL:        restoreDefaultPlotSettings()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function restoreDefaultPlotSettings()
  
  plotSettings = getappdata(0,'defaultPlotSettings');
  
  if ~isempty(plotSettings)
    settings = fieldnames(plotSettings);
    for ii = 1:numel(settings);
      set(0, settings{ii}, plotSettings.(settings{ii}));
    end
  else
    warning('LTPDA:restoreDefaultPlotSettings', '!!! No plot settings are stored');
  end
  
end
