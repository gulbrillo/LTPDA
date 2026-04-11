% Install all extension modules declared in the user's preferences.
%
% M Hewitson
%
function varargout = installExtensions(varargin)
  
  paths = utils.modules.getExtensionDirs;
  res = [];
  for kk = 1:numel(paths)
    p = paths{kk};
    % install
    res(kk) = utils.modules.installExtensionsForDir(p, varargin{:});
  end
  
  varargout{1} = any(res);
end
