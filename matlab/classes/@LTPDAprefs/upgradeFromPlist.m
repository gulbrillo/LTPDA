% UPGRADEFROMPLIST upgrades the old preference strucure to the new structure.
%
% Call:        prefs = LTPDAprefs.upgradeFromPlist(prefs, pl)
%
% Parameters:
%       prefs - preferences object with the new structure
%       pl    - a PLIST with the old preferences object. The old
%               preferences object must have the key 'LTPDAPREFERENCES'
%

function prefs = upgradeFromPlist(prefs, pl)
  
  oldprefs = pl.find('LTPDAPREFERENCES');
  
  disp('*** upgrading preferences ...');
  
  % update display settings
  prefs.getDisplayPrefs.setDisplayVerboseLevel(java.lang.Integer(oldprefs.display.verboseLevel));
  prefs.getDisplayPrefs.setDisplayWrapStrings(java.lang.Integer(oldprefs.display.wrapstrings));
  prefs.getDisplayPrefs.setDisplayWrapLegendStrings(java.lang.Integer(oldprefs.display.wraplegendstring));
  
  % update models
  for kk=1:numel(oldprefs.models.paths)
    path = oldprefs.models.paths{kk};
    prefs.getModelsPrefs.addSearchPath(path);
  end
  
  % update time prefs
  prefs.getTimePrefs.setTimeTimezone(oldprefs.time.timezone);
  prefs.getTimePrefs.setTimestringFormat(oldprefs.time.format);
  
  % update repository prefs
  for kk=1:numel(oldprefs.repository.servers)
    server = oldprefs.repository.servers{kk};
    prefs.getRepoPrefs.addHostname(server);
  end
  prefs.getRepoPrefs.setExpiry(java.lang.Integer(oldprefs.repository.loginExpiry));
  
  % update external prefs
  prefs.getExternalPrefs.setDotBinaryPath(oldprefs.external.dotbin);
  prefs.getExternalPrefs.setDotOutputFormat(oldprefs.external.dotformat);
  
  % update misc prefs
  prefs.getMiscPrefs.setDefaultWindow(oldprefs.misc.default_window.type);
  for kk=1:numel(oldprefs.misc.units)
    unit = oldprefs.misc.units{kk};
    prefs.getMiscPrefs.addUnit(unit);
  end
  
  oldprefs = [];
  
end
