% A function to properly clear MATLAB memory for LTPDA.
%
% M Hewitson 06-08-08
%
% $Id$
%

% Remove this object from memory so we can clear classes
% prefs = getappdata(0, 'LTPDApreferences');
% prefs.misc.default_window = '';

% TODO: We need to close all GUIs before doing this - Prefs GUI and Repo Gui

function mc()
  
  % remove preferences
  try
    rmappdata(0, 'LTPDApreferences');
  end
  
  % remove database connection manager
  try
    rmappdata(0, 'LTPDADatabaseConnectionManager');
  end
  
  % close windows
  close all;
  
  % clear variables
  evalin('caller', 'clear');         % delete the timer-objects
  clear classes                      % delete the local variables
  evalin('caller', 'clear classes'); % delete the variables in the caller function
  evalin('base', 'clear classes');   % delete the variables in the 'base' workspace
  
  % load the preferences again
  LTPDAprefs.loadPrefs();
  
  % reset plot styles
  prefs = getappdata(0, 'LTPDApreferences');
  styles = prefs.getPlotstylesPrefs();
  styles.resetStyleIndex();
  
  % make sure warnings are back to default on
  warning on;
  
end
