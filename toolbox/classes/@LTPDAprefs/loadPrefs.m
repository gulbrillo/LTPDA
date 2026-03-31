% LOADPREFS a static method which loads the preferences from a XML file.
%
% Call:        LTPDAprefs.loadPrefs()
%
% Parameters:
%        -
%

function loadPrefs(varargin)
  v = ver('LTPDA');
  nv = utils.helper.ver2num(v(1).Version);
  prefs = mpipeline.ltpdapreferences.LTPDAPreferences.loadFromDisk(LTPDAprefs.preffile, nv);
  
  % Version 2.4 drops support for built-in model directories.
  if (nv >= 2.04) 
    % we drop support for 'models' here, so check for non-empty models path
    % and warn the user to make an extension
    searchPaths = prefs.getModelsPrefs.getSearchPaths;
    paths = {};
    for kk=0:searchPaths.size-1
      paths = [paths {char(searchPaths.get(kk))}];
    end    
    if ~isempty(paths)
      message = sprintf('Directories of built-in models are no longer supported. \nPlease make an LTPDA Extension module for your models. \n(See document section "LTPDA Extension Modules").\n');
      utils.helper.warnDlg(message, 'Built-in model directories not supported');
      prefs.getModelsPrefs.getSearchPaths.clear();
    end
  end
    
  setappdata(0, 'LTPDApreferences', prefs);
  LTPDAprefs.setApplicationData();
  prefs.writeToDisk;
end
