% SETPREFERENCE A static method which sets a new value to the specified preference.
%
% Call:        LTPDAprefs.setPreference(category, property, value)
%
% Parameters:
%       category - Category of the preference
%       property - Property of the preference
%       value    - new value
%

function setPreference(category, property, value)
  prefs = getappdata(0, 'LTPDApreferences');
  if isempty(prefs)
    error('### No LTPDA Preferences found in memory. Please run ltpda_startup.');
  end
  
  switch category
    
    case 'display'
      cprefs = prefs.getDisplayPrefs;
      switch property
        case 'verboseLevel'
          clear +utils/@helper/msg_nnl
          clear +utils/@helper/warn
          cprefs.setDisplayVerboseLevel(java.lang.Integer(value));
          displayValueSet(category, property, double(cprefs.getDisplayVerboseLevel));
        case 'wrapstrings'
          cprefs.setDisplayWrapStrings(java.lang.Integer(value));
          displayValueSet(category, property, double(cprefs.getDisplayWrapStrings));
        case 'key action'
          switch lower(value)
            case 'none'
              cprefs.setDisplayKeyAction(java.lang.Integer(0));
              displayValueSet(category, property, upper(value));
            case 'warning'
              cprefs.setDisplayKeyAction(java.lang.Integer(1));
              displayValueSet(category, property, upper(value));
            case 'error'
              cprefs.setDisplayKeyAction(java.lang.Integer(2));
              displayValueSet(category, property, upper(value));
            otherwise
              error('Unknown value [%s] for category [%s] and property [%s]', char(value), category, property);
          end
        otherwise
          help LTPDAprefs
          error('Unknown property [%s] for category [%s]', property, category);
      end
      
    case 'plot'
      pprefs = prefs.getPlotPrefs;
      switch property
        case 'axesFontSize'
          pprefs.setPlotDefaultAxesFontSize(java.lang.Integer(value));
          displayValueSet(category, property, double(pprefs.getPlotDefaultAxesFontSize));
        case 'axesFontWeight'
          pprefs.setPlotDefaultAxesFontWeight(value);
          displayValueSet(category, property, char(pprefs.getPlotDefaultAxesFontWeight));
        case 'axesLineWidth'
          pprefs.setPlotDefaultAxesLineWidth(java.lang.Integer(value));
          displayValueSet(category, property, double(pprefs.getPlotDefaultAxesLineWidth));
        case 'gridStyle'
          pprefs.setPlotDefaultAxesGridLineStyle(value);
          displayValueSet(category, property, char(pprefs.getPlotDefaultAxesGridLineStyle));
        case 'minorGridStyle'
          pprefs.setPlotDefaultAxesMinorGridLineStyle(value);
          displayValueSet(category, property, char(pprefs.getPlotDefaultAxesMinorGridLineStyle));
        case 'legendFontSize'
          pprefs.setPlotDefaultLegendFontSize(java.lang.Integer(value));
          displayValueSet(category, property, char(pprefs.getPlotDefaultLegendFontSize));
        case 'includeDescription'
          pprefs.setPlotDefaultIncludeDescription(java.lang.Boolean(value));
          displayValueSet(category, property, char(pprefs.getPlotDefaultIncludeDescription));
        otherwise
          help LTPDAprefs
          error('Unknown property [%s] for category [%s]', property, category);
      end
      
    case 'extensions'
      eprefs = prefs.getExtensionsPrefs;
      switch property
        case 'add paths'
          value = cellstr(value);
          for ii = 1:numel(value)
            p = value{ii};
            if ischar(p) && exist(p, 'dir')
              eprefs.addSearchPath(p);
              utils.modules.installExtensionsForDir(p);
              displayValueSet(category, property, p);
            else
              error('It is not possible to add the path [%s] because it doesn''t exist.', char(p))
            end
          end
        case 'remove paths'
          value = cellstr(value);
          for ii = 1:numel(value)
            p = value{ii};
            if ischar(p)
              eprefs.removePaths(p);
              utils.modules.uninstallExtensionsForDir(p);
              displayValueSet(category, property, p);
            else
              error('It is not possible to remove the path [%s] because it doesn''t exist.', char(p))
            end
          end
        otherwise
          help LTPDAprefs
          error('Unknown property [%s] for category [%s]', property, category);
      end
      
    case 'time'
      tprefs = prefs.getTimePrefs;
      switch property
        case 'timezone'
          tprefs.setTimeTimezone(value);
          displayValueSet(category, property, char(tprefs.getTimeTimezone));
        case 'timeformat'
          tprefs.setTimestringFormat(value);
          displayValueSet(category, property, char(tprefs.getTimestringFormat));
        otherwise
          help LTPDAprefs
          error('Unknown property [%s] for category [%s]', property, category);
      end
      
    case 'misc'
      mprefs = prefs.getMiscPrefs;
      switch property
        case 'default_window'
          mprefs.setDefaultWindow(value);
          displayValueSet(category, property, char(mprefs.getDefaultWindow));
        otherwise
          help LTPDAprefs
          error('Unknown property [%s] for category [%s]', property, category);
      end
      
    otherwise
      help LTPDAprefs
      error('Unknown preference category %s', category)
  end
  
  prefs.writeToDisk();
  
end

function displayValueSet(category, property, value)
  if ischar(value)
    fprintf('* set %s/%s to [%s]\n', category, property, value);
  else
    fprintf('* set %s/%s to [%d]\n', category, property, value);
  end
end

