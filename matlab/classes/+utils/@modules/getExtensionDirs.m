function varargout = getExtensionDirs(varargin)
  
  % Get a list of user extension directories
  prefs = getappdata(0, 'LTPDApreferences');
  searchPaths = prefs.getExtensionsPrefs.getSearchPaths;
  paths = {};
  for kk = 0:searchPaths.size-1
    paths = [paths {char(searchPaths.get(kk))}];
  end
  
  varargout{1} = paths;
  
end