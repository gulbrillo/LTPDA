% GETDESCRIPTION builds a description string from the model
% 
% CALL: utils.models.getDescription(@getModelDescription, @versionTable, version, @getFileVersion)
% 
function desc = getDescription(varargin)
  getModelDescription = varargin{1};
  options = {};
  if nargin > 1
      options = varargin(1:end);
  end
  desc = getModelDescription();

%   if numel(options)>=3 && ischar(options{3})
%     fcn = utils.models.functionForVersion(options{:});
%     desc = [desc ' ' fcn('description')];
%   end
  
end