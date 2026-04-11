% FUNCTIONFORVERSION returns the function handle for a given version string
% 
% CALL: utils.models.functionForVersion(@getModelDescription, @versionTable, version, @getFileVersion)
% 
function fcn = functionForVersion(getModelDescription, versionTable, version, getVersion)
  if isa(versionTable, 'function_handle')
    vt = versionTable();
  else
    vt = versionTable;
  end
  idx = find(strcmp(vt, version));
  if isempty(idx)
    error('requested version [%s] does not exist', version);
  end
  fcn = vt{idx+1};
end