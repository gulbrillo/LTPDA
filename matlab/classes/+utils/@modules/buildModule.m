% BUILDMODULE builds a new module structure in the location specified by
% the user.
%
% CALL:   utils.modules.buildModule(dir, module_name)
%
% INPUTS:
%              dir - the directory in which to build the module
%      module_name - a name for the new module
%
% Example:
%
%        utils.modules.buildModule('~/work', 'myNewModule')
%
%
% The resulting module structure on disk looks like:
%
% module/
%   |- classes
%   |- functions
%   |- jar
%   |- models
%   |- tests
%        |- classes
%        |- models
%
%

function varargout = buildModule(varargin)
  
  if nargin ~= 2
    help(['utils.modules.' mfilename]);
    error('incorrect inputs');
  end
  
  % Inputs
  mdir = varargin{1};
  if ~ischar(mdir)
    error('The first input should be a string indicating a directory on disk');
  end
  
  mname = varargin{2};
  if ~ischar(mname)
    error('The second input should be a string indicating the module name');
  end
  
  % Make module
  mpath = fullfile(mdir, mname);
  paths = {'classes', 'functions', 'jar', 'models', 'pipelines', 'examples', 'tests', ...
    fullfile('tests', 'classes'), fullfile('tests', 'models')};
  
  % Check if the directory for the new module exists
  if isdir(mpath)
    r = input(sprintf('A directory exists at the chosen location (%s). \nDo you want to overwrite it? (yes/no) ', mpath), 's');
    if ~strcmpi(r, 'yes')
      return;
    end
  end
  
  % Make module dir
  [success,message,messageid] = mkdir(mdir,mname);
  if ~success
    error(messageid, 'Failed to make module directory. %s', message);
  end
  
  % Make all the sub directories
  for kk=1:numel(paths)
    p = paths{kk};
    [success,message,messageid] = mkdir(mpath, p);
    if ~success
      error(messageid, 'Failed to make module directory %s.\n %s', fullfile(mpath, p), message);
    end
  end
  
  % create README
  fd = fopen(fullfile(mpath, 'README.txt'), 'w+');
  fprintf(fd, 'LTPDA Module %s\n', mname);
  fprintf(fd, '\n');
  fprintf(fd, '\n');
  fprintf(fd, 'For further details see the following README files:\n');
  fprintf(fd, '   classes/README_classes.txt\n');
  fprintf(fd, '   functions/README_functions.txt\n');
  fprintf(fd, '   jar/README_jar.txt\n');
  fprintf(fd, '   models/README_models.txt\n');
  fprintf(fd, '   pipelines/README_pipelines.txt\n');
  fprintf(fd, '   tests/README_tests.txt\n');
  fprintf(fd, '   tests/classes/README_class_tests.txt\n');
  fprintf(fd, '   tests/models/README_model_tests.txt\n');
  fprintf(fd, '\n');
  fprintf(fd, '\n');
  fclose(fd);
  
  % copy in the README files
  src = fileparts(which('utils.modules.buildModule'));
  installREADME(src, 'README_classes.txt', mpath, 'classes');
  installREADME(src, 'README_functions.txt', mpath, 'functions');
  installREADME(src, 'README_jar.txt', mpath, 'jar');
  installREADME(src, 'README_models.txt', mpath, 'models');
  installREADME(src, 'README_pipelines.txt', mpath, 'pipelines');
  installREADME(src, 'README_tests.txt', mpath, 'tests');
  installREADME(src, 'README_class_tests.txt', mpath, fullfile('tests', 'classes'));
  installREADME(src, 'README_model_tests.txt', mpath, fullfile('tests', 'models'));
  
  
  % Write moduleinfo.xml
  writeModuleInfoXML(mpath, mname);  
  
  ls(mpath)
  fprintf('* Module built successfully at %s\n', mpath);
  
end

function writeModuleInfoXML(mpath, name)
  
  docNode = com.mathworks.xml.XMLUtils.createDocument('moduleinfo');
  docRootNode = docNode.getDocumentElement;
  docRootNode.setAttribute('name',name);
  docRootNode.setAttribute('version','1.0');
  

  % Save the sample XML document.
  % Due to Java limitaton in handling ~, we need to move in the destination directory
  wd = cd(mpath);
  xmlFileName = fullfile('moduleinfo.xml');
  xmlwrite(xmlFileName,docNode);
  cd(wd);
end

function installREADME(src, name, mpath, mdir)
  
  src = fullfile(src, name);
  dest = fullfile(mpath, mdir);
  [success,message,messageid] = copyfile(src, dest);
  if ~success
    error(messageid, 'Failed to copy %s to %s', src, dest);
  end
  
end

% END
