% MODULEINFO returns a structure containing information about the module.
%
% CALL
%            info = utils.modules.moduleInfo(path_to_module)
%
% Information structure:
%
%           info.name    % module name
%           info.version % module version
%

function info = moduleInfo(varargin)
  
  if nargin ~= 1
    help(mfilename);
    error('Incorrect usage');
  end
  
  mpath = varargin{1};
  
  info.name = '';
  info.version = '';
  
  % Due to Java limitaton in handling ~, we need to move in the destination directory
  wd = cd(mpath);  
  try
    xmlFileName = fullfile('./moduleinfo.xml');
    xDoc = xmlread(xmlFileName);
    xRoot = xDoc.getDocumentElement;
    info.name = char(xRoot.getAttribute('name'));
    info.version = char(xRoot.getAttribute('version'));
  catch Me
    % In case it failed, make sure we go back
    cd(wd);
    rethrow(Me);
  end
  
  % Now go back to the other directory
  cd(wd);
end
% END
