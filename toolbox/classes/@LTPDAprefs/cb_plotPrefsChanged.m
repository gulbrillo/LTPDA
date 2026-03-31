% cb_addModelPath callback for adding a model path
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: java PlotPrefGroup)
%       third  - Event Object (here: PropertyChangeEvent)
%

function cb_plotPrefsChanged(varargin)
  
  mLtpdaPrefs = varargin{1};
  jPlotPrefGroup = varargin{2};
  jPropChangeEvent = varargin{3};
  
  jPropName = jPropChangeEvent.getPropertyName();
  jNewVal = jPropChangeEvent.getNewValue();
  
  jPlotPrefs = jPlotPrefGroup.getPlotPrefs();
  
  % Set the plot preferences only to the default-application-data if the
  % user chose: 'Apply plot settings to all figures'.
  if ~isempty(jPropName) && ...
      (jPlotPrefs.getPlotApplyPlotSettings.equals(mpipeline.ltpdapreferences.EnumPlotSetting.ALL_FIGURES))
    
    if mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      % Backup current plot settings
      utils.plottools.backupDefaultPlotSettings();
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_AXES_FONT_SIZE_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      set(0, 'DefaultAxesFontSize', double(jPlotPrefs.getPlotDefaultAxesFontSize));
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_AXES_LINE_WIDTH_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      set(0, 'DefaultAxesLineWidth', double(jPlotPrefs.getPlotDefaultAxesLineWidth));
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_AXES_GRID_LINE_STYLE_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      set(0, 'DefaultAxesGridLineStyle', char(jPlotPrefs.getPlotDefaultAxesGridLineStyle));
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_AXES_MINOR_GRID_LINE_STYLE_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      set(0, 'DefaultAxesMinorGridLineStyle', char(jPlotPrefs.getPlotDefaultAxesMinorGridLineStyle));
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_AXES_FONT_WEIGHT_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      switch lower(char(jPlotPrefs.getPlotDefaultAxesFontWeight))
        case 'plain'
          set(0, 'DefaultAxesFontWeight', 'normal');
        case 'bold'
          set(0, 'DefaultAxesFontWeight', 'bold');
        case 'italic'
          set(0, 'DefaultAxesFontWeight', 'light');
        case 'bold italic'
          set(0, 'DefaultAxesFontWeight', 'demi');
        otherwise
          error('### Unknown value (%s) for the default axes property ''FontWeight''', char(jPlotPrefs.getPlotDefaultAxesFontWeight));
      end
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_DEFAULT_LEGEND_FONT_SIZE_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      % Nothing to do. There doesn't exist any application value.
      % We have to change the axis-handle of the legend.
      % There exist only a general axes-font-size and not a special for the legends.
    end
    
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_INCLUDE_DESCRIPTION_CHANGED.equals(jPropName) || ...
        mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      % Nothing to do. There doesn't exist any application value.
    end
    
  else
    % Restore MATLAB plot setting only if the user changed 'Apply plot settings: ...'
    if  mpipeline.ltpdapreferences.PlotPrefGroup.PLOT_APPLY_PLOT_SETTINGS_CHANGED.equals(jPropName)
      warning('LTPDA:cb_plotPrefsChanged', '!!! Recover MATLAB''s default plot settings.');
      utils.plottools.restoreDefaultPlotSettings();
    end
  end
  
end
