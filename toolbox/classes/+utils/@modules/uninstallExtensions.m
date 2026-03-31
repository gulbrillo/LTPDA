% Uninstall all extension modules declared in the user's preferences.
%
% M Hewitson
%
function varargout = uninstallExtensions(varargin)

  paths = utils.modules.getExtensionDirs;
  
  for kk = 1:numel(paths)
    p = paths{kk};
    utils.modules.uninstallExtensionsForDir(p);
  end  
  
end
