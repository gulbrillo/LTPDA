% RELEASEMODULE prepares an extension module for release.
%
% The steps are:
%  1) check-out a temporary copy of the module from VCS
%  2) create a <MODULE_NAME>.hash file
%  3) create zip of the folder with version and put the zip file in the place the user asks
%  4) delete the VCS folder
%  5) delete the temporary checked out folder
%
% CALL:  zippath = utils.modules.releaseModule(URL, moduleDir, vers_syst, vcs_module_version, outputDir)
%
% INPUTS: a plist with the fields:
%                  URL - the URL of the VCS source
%            moduleDir - the directory within the VCS module containing the
%                        extension module.
%                  vcs - the Version Control System used for the development of the module
%               branch - the branch of the VCS repository to checkout
%            outputDir - the place to put the final zip file
%          credentials - the place to put the final zip file
%
% OUTPUTS:
%              zippath - a path to the created zip file
%
% Example:
% 
% pl = plist(...
%   'URL', 'git@gitmaster.atlas.aei.uni-hannover.de:ltpda/ltpda_extensions.git', ...
%   'moduleDir', 'LPF_DA_Module', ...
%   'vcs', 'git', ...
%   'branch', 'release_2_5_5', ...
%   'outputDir', '~/releases/' ...
%   );
%
% zippath = utils.modules.releaseModule(pl)
%

function varargout = releaseModule(varargin)

  % Leave function if the OS is not a UNIX or MAC system
  if ~(isunix || ismac)
    error('### It is only possible to execute this function on a UNIX or MAC system');
  end

  % Combine with defaults
  usepl = applyDefaults(getDefaultPlist, varargin{1});
  
  vers_syst          = usepl.find('vcs');
  vcs_module_version = usepl.find('branch');
  
  % Get unique temporary file name
  tmpDir = tempname();
  
  % Download a temporary copy of the module from VCS
  tmpModuleDir = getModuleSource(usepl, tmpDir);
  
  % Retrieve the name of the module from the module info xml file
  info = utils.modules.moduleInfo(tmpModuleDir);
  moduleName = info.name;
  
  hashFile = sprintf('%s.hash', moduleName);
  
  % create a <MODULE_NAME>.hash file
  [result, message] = utils.modules.generateHash(vers_syst, tmpModuleDir, tmpModuleDir, hashFile);
  
  if ~result
    error(message);
  end
  
  % Remove '.<VCS>' folder if existing
  removeVCSFolders(vers_syst, tmpModuleDir);
  
  % Rename temporary directory to module name
  [tmpModulePath] = fileparts(tmpModuleDir);
  renamedModulePath = fullfile(tmpModulePath, moduleName);
  if ~strcmp(renamedModulePath, tmpModuleDir)
    execSystemCmd(sprintf('mv %s %s', tmpModuleDir, renamedModulePath));
    tmpModuleDir = renamedModulePath;
  end
  
  % ZIP module
  if ~isempty(vcs_module_version)
    zipFileName = sprintf('%s_%s.zip', moduleName, vcs_module_version);
  else
    zipFileName = sprintf('%s.zip', moduleName);
  end
  zipFile = fullfile(tmpModulePath, zipFileName);
  
  zip(zipFile, tmpModuleDir);
  
  % Move the ZIP file in the output folder
  outputDir = usepl.find('outputdir');
  if ~isempty(outputDir)
    outputFile = fullfile(outputDir, zipFileName);
    execSystemCmd(sprintf('mv %s %s', zipFile, outputFile));
  end
  
  % Delete temporary directories
  if exist(tmpDir, 'dir')
    execSystemCmd(sprintf('rm -rf %s', tmpDir));
  end
  if exist(tmpModuleDir, 'dir')
    execSystemCmd(sprintf('rm -rf %s', tmpModuleDir));
  end
  
  % Prepare outputs
  varargout = {outputFile};
end

function tmpModuleDir = getModuleSource(pl, tmpModuleDir)
  
  URL                = pl.find('URL');
  moduleDir          = pl.find('moduledir');
  vers_syst          = pl.find('vcs');
  credentials        = pl.find('credentials');
  vcs_revision       = pl.find('revision');
  vcs_branch         = pl.find('branch');
  
  switch upper(vers_syst)
    case 'GIT'
      if isempty(vcs_branch)
        vcs_branch = 'master';
      end
      cmd = sprintf('git clone %s -b %s %s;', ...
        URL, vcs_branch, tmpModuleDir);
      
    case 'SVN'
      if ~isempty(vcs_revision)
        rev_str = sprintf('--revision %s', vcs_revision);
      else
        rev_str = '';
      end
      cmd = sprintf('svn checkout %s --username %s --password %s %s/%s %s', ...
        rev_str, credentials.username, credentials.password, URL, moduleDir, tmpModuleDir);
      
    case 'HG'
      if isempty(vcs_branch)
        vcs_branch = 'default';
      end
      cmd = sprintf('hg clone %s/%s -b %s %s', URL, moduleDir, vcs_branch, tmpModuleDir);
      
    otherwise
      cmd = [];
      
  end
  
  switch upper(vers_syst)
    case {'GIT', 'HG'}
      % In this case we also need to include the module folder
      if ~strcmp(moduleDir, './')
        tmpModuleDir = fullfile(tmpModuleDir, moduleDir);
      end
    otherwise
  end
  
  execSystemCmd(cmd);
  
end

function removeVCSFolders(vers_syst, tmpModuleDir)
  
  % Remove '.<VCS>' folder if exists
  vcs_folder = fullfile(tmpModuleDir, sprintf('.%s',  lower(vers_syst)));
  if exist(vcs_folder, 'dir')
    execSystemCmd(sprintf('rm -rf %s', vcs_folder));
  end
  switch upper(vers_syst)
    case 'HG'
      execSystemCmd(sprintf('rm -rf .hgcheck .hgignore .hgtags'));
  end
  
end

function execSystemCmd(cmd)
  [status, result] = system(cmd);
  if status ~= 0
    error(result);
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  % Start with empty plist
  pl = plist();
  
  % URL
  p = param({'URL', ['The URL of the VCS source']}, 'git@gitmaster.atlas.aei.uni-hannover.de:ltpda/ltpda_extensions.git');
  pl.append(p);
  
  % VCS
  p = param({'VCS', ['The Version Control System used for the development of the module. Choose between:<ul>', ...
    '<li>git</li>', ...
    '<li>svn</li>', ...
    '<li>hg</li></ul>']}, {1, {'git', 'svn', 'hg'}, paramValue.SINGLE});
  pl.append(p);
  
  % moduleDir
  p = param({'moduledir', ['The subfolder within the VCS containing the LTPDA extension module']}, './');
  pl.append(p);
  
  % outputDir
  p = param({'outputdir', ['The folder where to put the final zip file']}, './');
  pl.append(p);
  
  % version
  p = param({'revision', ['The revision number for the release. <br>Please provide a string!']}, '');
  pl.append(p);

  % branch
  p = param({'branch', ['The branch of the repository to checkout. <br>Please provide a string!']}, '');
  pl.append(p);

  % credentials
  p = param({'credentials', ['A struct with ''username'' and ''password'' fields. <br>' ...
    'This applies only to svn.']}, struct());
  pl.append(p);
  
end

