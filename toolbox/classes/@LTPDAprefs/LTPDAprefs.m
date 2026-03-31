% LTPDAprefs is a graphical user interface for editing LTPDA preferences.
%
% CALL: LTPDAprefs
%       LTPDAprefs(h) % build the preference panel in the figure with handle, h.
%
%       LTPDAprefs(cat, property, value) % Set the temporary value of a property
%
% Category and property names are case sensitive.
%
% The properties that can be set are
%
%  Category    |    Property         | Description
% -------------------------------------------------------------------------
%  display     |  'verboseLevel'       | Set the level of terminal output from LTPDA
%              |                       | (see "help utils.const.msg" for
%              |                       | supported levels).
% -------------------------------------------------------------------------
%              |  'wrapstrings'        | Set the point where strings are wrapped in
%              |                       | some methods of LTPDA.
% -------------------------------------------------------------------------
%              |  'key action'         | Set the supported key action.
%              |                       | Possible values are:
%              |                       | 'NONE', 'WARNING', 'ERROR'
% -------------------------------------------------------------------------
%  plot        |  'axesFontSize'       | Set the font size for new plot axes
% -------------------------------------------------------------------------
%              |  'axesFontWeight'     | Set the font weight for new plot axes
% -------------------------------------------------------------------------
%              |  'axesLineWidth'      | Set the line width for new plot axes
% -------------------------------------------------------------------------
%              |  'gridStyle'          | Set the grid line style for new axes
% -------------------------------------------------------------------------
%              |  'minorGridStyle'     | Set the minor-grid line style for new axes
% -------------------------------------------------------------------------
%              |  legendFontSize'      | Set the font size for the legend
% -------------------------------------------------------------------------
%              |  'includeDescription' | Set the description of an object to the plot
% -------------------------------------------------------------------------
%  extensions  |  'add paths'          | Installs the toolbox extensions
%              |                       | found under the given directory.
% -------------------------------------------------------------------------
%              |  'remove paths'       | Uninstalls the toolbox extensions
%              |                       | found under the given directory.
% -------------------------------------------------------------------------
%  time        |  'timezone'           | Set the timezone used to display time
%              |                       | objects. (>> time.getTimezones)
% -------------------------------------------------------------------------
%              |  'timeformat'         | Set the format for displaying time objects
% -------------------------------------------------------------------------
%  misc        |  'default_window'     | The default spectral window object for
%              |                       | use by LTPDA's spectral analysis tools
% -------------------------------------------------------------------------
%
% Example: to set the verbose level of LTPDA from the command-line:
%
% >> LTPDAprefs('Display', 'verboseLevel', 3)
%
% The value of all properties in the table can also be retrieved by:
%
% >> LTPDAprefs.<property_name>
%
% for example,
%
% >> vl = LTPDAprefs.verboseLevel;
%
%

classdef LTPDAprefs < handle
  
  properties (Constant = true)
    oldpreffile = fullfile(prefdir, 'ltpda_prefs.xml');
    preffile = fullfile(prefdir, 'ltpda_prefs2.xml');
  end
  
  properties
    gui = [];
  end
  
  
  methods
    function mainfig = LTPDAprefs(varargin)
      
      if nargin == 3 && ischar(varargin{1}) && ischar(varargin{2})
        
        %--- set preference by command-line
        
        category  = lower(varargin{1});
        property  = varargin{2};
        value     = varargin{3};
        
        LTPDAprefs.setPreference(category, property, value);
        
      else
        % -- load GUI
        
        % get prefs from appdata
        prefs = getappdata(0, 'LTPDApreferences');
        
        % make a gui with a icon on the taskbar
        frame = javax.swing.JFrame('LTPDApreferences');
        frame.setUndecorated(true);
        frame.setVisible(true);
        frame.setLocationRelativeTo([]);
        mainfig.gui = javaObjectEDT('mpipeline.ltpdapreferences.LTPDAPrefsGui', frame, false, prefs);
        
%         % make a gui without a icon on the taskbar
%         mainfig.gui = javaObjectEDT('mpipeline.ltpdapreferences.LTPDAPrefsGui', [], false, prefs);
        
        % upload the available window types
        winTypes = specwin.getTypes;
        for kk=1:numel(winTypes)
          javaMethodEDT('addAvailableWindow', mainfig.gui, winTypes{kk});
        end
        
        %--- called when window is closed
        h = handle(mainfig.gui, 'callbackproperties');
        set(h, 'WindowClosedCallback', {@mainfig.cb_guiClosed});
        
        %--- called when verbose level is changed
        h = handle(mainfig.gui.getPrefsTabPane().getDisplayPanel().getVerboseLevelCombo(), 'callbackproperties');
        set(h, 'ActionPerformedCallback', {@mainfig.cb_verboseLevelChanged});
        
        %--- Add extension path button
        h = handle(mainfig.gui.getPrefsTabPane().getExtensionsPanel().getAddPathBtn(), 'callbackproperties');
        set(h, 'ActionPerformedCallback', {@mainfig.cb_addExtensionPath});
        
        %--- Remove extension path button
        h = handle(mainfig.gui.getPrefsTabPane().getExtensionsPanel().getRemovePathBtn(), 'callbackproperties');
        set(h, 'ActionPerformedCallback', {@mainfig.cb_removeExtensionPath});
        
        %--- Plot preferences changed
        h = handle(mainfig.gui.getPrefsTabPane().getPlotPanel(), 'callbackproperties');
        set(h, 'PropertyChangeCallback', {@mainfig.cb_plotPrefsChanged});
        
        %--- Timeformat preferences changed
        h = handle(mainfig.gui.getPrefsTabPane().getTimePanel().getTimestringTextEdit().getDocument(), 'callbackproperties');
        set(h, 'InsertUpdateCallback', {@mainfig.cb_timeformatChanged});
        set(h, 'RemoveUpdateCallback', {@mainfig.cb_timeformatChanged});
        set(h, 'ChangedUpdateCallback', {@mainfig.cb_timeformatChanged});
        
        %--- Timezone preferences changed
        h = handle(mainfig.gui.getPrefsTabPane().getTimePanel().getTimezoneCombo(), 'callbackproperties');
        set(h, 'ActionPerformedCallback', {@mainfig.cb_timezoneChanged});
        
        % Make gui visible
        mainfig.gui.setVisible(true);
        
      end
      
    end % End constructor
    
    function display(varargin)
    end
    
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (static)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static=true)
    
    %------------ add here the prototypes
    
    varargout = loadPrefs(varargin)
    varargout = upgradeFromPlist(varargin)
    varargout = setApplicationData(varargin)
    
    %------------ quick accessors for preferences
    
    % display
    function val = verboseLevel
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getDisplayPrefs.getDisplayVerboseLevel);
    end
    
    function val = wrapStrings
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getDisplayPrefs.getDisplayWrapStrings);
    end
    
    % plot
    function val = axesFontSize
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultAxesFontSize);
    end
    
    function val = axesFontWeight
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesFontWeight);
    end
    
    function val = axesLineWidth
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultAxesLineWidth);
    end
    
    function val = gridStyle
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesGridLineStyle);
    end
    
    function val = minorGridStyle
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getPlotPrefs.getPlotDefaultAxesMinorGridLineStyle);
    end
    
    function val = legendFontSize
      prefs = LTPDAprefs.getPreferences;
      val = double(prefs.getPlotPrefs.getPlotDefaultLegendFontSize);
    end
    
    function val = includeDescription
      prefs = LTPDAprefs.getPreferences;
      val = prefs.getPlotPrefs.getPlotDefaultIncludeDescription().booleanValue();
    end
    
    % extensions
    function val = extensionPaths
      prefs = LTPDAprefs.getPreferences;
      val = cell(prefs.getExtensionsPrefs.getSearchPaths.toArray);
    end
    
    % time
    function val = timezone
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getTimePrefs.getTimeTimezone);
    end
    
    function val = timeformat
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getTimePrefs.getTimestringFormat);
    end
    
    % misc
    function val = default_window
      prefs = LTPDAprefs.getPreferences;
      val = char(prefs.getMiscPrefs.getDefaultWindow);
    end
    
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = private, Static=true)
    
    prefs = getPreferences()
    setPreference(category, property, value)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private)                                 %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    
    cb_guiClosed(varargin)
    cb_verboseLevelChanged(varargin)
    cb_addExtensionPath(varargin)
    cb_removeExtensionPath(varargin)
    cb_plotPrefsChanged(varargin)
    cb_timeformatChanged(varargin)
    cb_timezoneChanged(varargin)
    
  end
  
end

% END
