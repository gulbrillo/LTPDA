% GETINFO Get Info Object
% 
% CALL: utils.models.getInfo(modelname, @getModelDescription, @versionTable, version, @getFileVersion)
% 
% 
function ii = getInfo(varargin)
  modelname = varargin{1};
  getVersion = varargin{5};
  if nargin == 6
    getPackageName = varargin{6};
    package = getPackageName();
    options = varargin(2:end-1);
  else
    options = varargin(2:end);
    package = 'Unknown';
  end
  
  pls = utils.models.getDefaultPlist(options{:});
  % Build info object
  parts = regexp(modelname, '_', 'split');
  ii = minfo(modelname, parts{1}, package, utils.const.categories.constructor, getVersion(), {}, pls);
  ii.setDescription(utils.models.getDescription(options{:}));
  fcn = utils.models.functionForVersion(options{:});
  ii.addChildren(fcn('info'));
end