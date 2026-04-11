% GETDEFAULTPLIST returns a default plist for the model 
% 
% CALL: utils.models.functionForVersion(@getModelDescription, @versionTable)
% CALL: utils.models.functionForVersion(@getModelDescription, @versionTable, version, @getFileVersion)
% 
function pl = getDefaultPlist(varargin)
    
  getModelDescription = varargin{1};
  versionTable = varargin{2};
  options = {};
  if nargin > 2
    if ischar(varargin{3})
      options = varargin(3);
    else
      options = varargin{3};
    end
  end
  
  % default plist for all model versions
  vt = versionTable();
  idx = 1; % we take the first version as default
  versions = vt(1:2:end);
  if numel(options)>=1 && ischar(options{1})
    if ~utils.helper.ismember(options{1}, versions)
      error('requested version [%s] does not exist', options{1});
    end
    idx = find(strcmp(options{1}, versions));
  end
  version = versions{idx};

  % add plist for this version
  fcn = utils.models.functionForVersion(getModelDescription, versionTable, version);
  pl = plist('version', vt{2*idx-1});
  pl.combine(fcn('plist'));
  pl.setName(sprintf('Parameter List for version: %s', version));
end
