% cb_guiClosed callback for closing the LTPDAprefs GUI
%
% Parameters:
%       first  - LTPDAprefs object
%       second - Source object (here: java LTPDAPrefsGui)
%       third  - Event Object (here: WindowEvent)
%

function cb_guiClosed(varargin)
  ltpdaPrefs = varargin{1};
  
  if ~isempty(ltpdaPrefs) && isvalid(ltpdaPrefs)
    fprintf('*** Goodbye from %s\n', class(ltpdaPrefs));
    
    %--- called when window is closed
    h = handle(ltpdaPrefs.gui, 'callbackproperties');
    set(h, 'WindowClosedCallback', []);
    
    %--- called when verbose level is changed
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getDisplayPanel().getVerboseLevelCombo(), 'callbackproperties');
    set(h, 'ActionPerformedCallback', []);
    
    %--- Add extension path button
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getExtensionsPanel().getAddPathBtn(), 'callbackproperties');
    set(h, 'ActionPerformedCallback', []);
    
    %--- Remove extension path button
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getExtensionsPanel().getRemovePathBtn(), 'callbackproperties');
    set(h, 'ActionPerformedCallback', []);
    
    %--- Plot preferences changed
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getPlotPanel(), 'callbackproperties');
    set(h, 'PropertyChangeCallback', []);
    
    %--- Timeformat preferences changed
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getTimePanel().getTimestringTextEdit().getDocument(), 'callbackproperties');
    set(h, 'InsertUpdateCallback', []);
    set(h, 'RemoveUpdateCallback', []);
    set(h, 'ChangedUpdateCallback', []);
    
    %--- Timezone preferences changed
    h = handle(ltpdaPrefs.gui.getPrefsTabPane().getTimePanel().getTimezoneCombo(), 'callbackproperties');
    set(h, 'ActionPerformedCallback', []);
    
    ltpdaPrefs.gui.setPrefs([]);
    
    %--- It is also necessary to destroy the GUI with the destructor 'delete'
    delete(ltpdaPrefs);
    
  end
  
end
