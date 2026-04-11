function varargout = getBuiltinModelSearchPaths(varargin)
  
  % Get a list of user model directories
  prefs = getappdata(0, 'LTPDApreferences');
  
  % support the old stand-alone built-in models directories
  searchPaths = prefs.getModelsPrefs.getSearchPaths;
  paths = {};
  for kk=0:searchPaths.size-1
    paths = [paths {char(searchPaths.get(kk))}];
  end
  
  % and add the new extension modules built-in models
  searchPaths = prefs.getExtensionsPrefs.getSearchPaths;
  for kk=0:searchPaths.size-1
    paths = [paths {fullfile(char(searchPaths.get(kk)), 'models')}];
  end
  
  % Always look in the system directory
  loc = mfilename('fullpath');
  idx = strfind(loc, filesep);
  loc = loc(1:idx(end));
  loc = fullfile(loc, '..', '..', '..', 'm', 'built_in_models');
  paths = [reshape(paths, 1, []) {loc}];
  
  % and the operations extensions folder
  loc = mfilename('fullpath');
  idx = strfind(loc, filesep);
  loc = loc(1:idx(end));
  opsexts = fullfile(loc, '..', '..', '..', '..', 'extensions');
  
  opsextdirs = dir(opsexts);
  for kk=1:numel(opsextdirs)
    d = opsextdirs(kk);
    if d.name(1) ~= '.'
      paths = [paths {fullfile(opsexts, d.name)}];
    end
  end
    
  varargout{1} = paths;
  
end