% INSTALLEXTENSIONSFORDIR installs the toolbox extensions found under the
% given directory.
%
% CALL: utils.modules.installExtensionsForDir(dir)
%
% M Hewitson 29-10-10
%

function res = installExtensionsForDir(varargin)
  
  import utils.const.*
  
  extdir = varargin{1};
  
  if nargin > 1 && islogical(varargin{2})
    do_install = varargin{2};
  else
    do_install = false;
  end
  
  if ~ischar(extdir)
    error('input a path to a directory of LTPDA extensions');
  end
  
  fprintf('* installing extensions under %s ...\n', extdir);
  
  % toolbox path
  aopath = fileparts(which('ao'));
  parts = regexp(aopath, '@', 'split');
  classpath = parts{1};
  
  % for each LTPDA user class, look for a corresponding directory and copy the
  % extension methods in.
  % copy <module>/classes/<user_class>/<methods> to the toolbox
  userclasses = utils.helper.ltpda_userclasses;
  installedClassMethods = false;
  for ucl = userclasses
    extsdir = fullfile(extdir, 'classes', ucl{1});
    if exist(extsdir, 'dir') == 7
      fprintf('  * installing extensions for class %s ...\n', ucl{1});
      files = utils.prog.filescan(extsdir, '.m');
      dstdir = fullfile(classpath, ['@' ucl{1}]);
      
      % Retrieve the content of the user class
      method_names = checkClassContent(ucl{1}, dstdir);
      
      for kk = 1:numel(files)
        f = files{kk};
        [path,name,ext] = fileparts(f);
        fprintf('      installing %s -> %s\n', name, ucl{1});
        if ~any(strcmpi(name, method_names))
          [success, message, messageid] = copyfile(f, dstdir);
          if ~success
            fprintf(2, 'Failed to copy file %s to %s : %s', f, dstdir, message);
          else
            installedClassMethods = true;
          end
        else
          utils.helper.msg(msg.IMPORTANT, 'The method ''%s/%s'' already exists in LTPDA. You cannot override it. Skipping!', ucl{1}, name);
        end
      end
    end
  end
  
  
  if do_install
    %
    % 1) Copy full extension module to <toolbox>/extensions
    ltpdaroot = getappdata(0, 'LTPDAROOT');
    ltpda_exts_dir = fullfile(ltpdaroot, 'extensions');
    mkdir(ltpda_exts_dir);
    
    parts = regexp(extdir, filesep, 'split');
    parts = parts(~cellfun(@isempty, parts));
    extNameDir = parts{end};
    dstdir = fullfile(ltpda_exts_dir, extNameDir);
    
    % Rather than just copy everything, we should generate a list of
    % directories to copy and remove those which are under classes but are
    % not @something. It's the same list we iterated over above to install
    % the additional class methods. We can use genpath on the extdir and
    % filter out those that are in that list. Then copy the remaining ones
    % over.
    
    dirsToCopy = utils.prog.dirscan(extdir, '.*'); %regexp(genpath(extdir), ':', 'split');
    dirsToCopy = dirsToCopy(2:end);
    dirsNotToCopy = fullfile(extNameDir, 'classes', userclasses);
    
    % filter out tests folder
    dirsToCopy = dirsToCopy(cellfun(@isempty, regexp(dirsToCopy, 'tests', 'match')));
    
    for kk=1:numel(dirsToCopy)
      
      % remove directory if it ends in classes/<userclass>
      if any(~cellfun(@isempty, regexp(dirsToCopy{kk}, dirsNotToCopy))) || ...
          dirsToCopy{kk}(end) == '.' || ...
          strcmp(dirsToCopy{kk}(end-6:end), 'classes')
        
        fprintf(' -- not copying extension directory [%s]\n', dirsToCopy{kk});
        dirsToCopy{kk} = [];
      end
    end
    
    dirsToCopy = dirsToCopy(~cellfun(@isempty, dirsToCopy));
    
    for kk=1:numel(dirsToCopy)
      sourceDir = dirsToCopy{kk};
      
      parts = regexp(sourceDir, extNameDir, 'split');
      dirDstDir = fullfile(dstdir, parts{2});
      
      % make sure this exists
      [success, message, messageid] = mkdir(dirDstDir);
      
      % for the destination, we need the path after extension name and append
      % that to the dstdir
      fprintf('Copying %s -> %s \n', sourceDir, dirDstDir);
      [success, message, messageid] = copyfile(sourceDir, dirDstDir);
      if ~success
        fprintf(2, 'Failed to copy file %s to %s : %s', sourceDir, dirDstDir, message);
      end
    end
    
    % copy all files in root of extension
    extdir
    filesToCopy = dir(extdir)
    filesToCopy = filesToCopy(~[filesToCopy.isdir])
    filesToCopy = fullfile(extdir, [{filesToCopy.name}])
    
    for kk=1:numel(filesToCopy)
      sourceFile = filesToCopy{kk};
      dstFile = dstdir;
      fprintf('Copying %s -> %s \n', sourceFile, dstFile);
      [success, message, messageid] = copyfile(sourceFile, dstFile);
      if ~success
        fprintf(2, 'Failed to copy file %s to %s : %s', sourceFile, dstFile, message);
      end
    end
    
    extdir = dstdir;
    
    %---- Remove particular files types from the destination    
    extensions = {'.tex'};
    for jj=1:numel(extensions)
      texFiles = utils.prog.filescan(extdir, extensions{jj});
      for kk=1:numel(texFiles)
        fprintf('- Deleting %s\n', texFiles{kk});
        delete(texFiles{kk});
      end
    end    
    
  end % End if do_install
  
  % Add subdirs to the MATLAB path
  addpath(extdir);
  % In order to include user-defined classes, we just need to add the <module>/classes folder
  addpath(fullfile(extdir, 'classes'));
  % In order to include user-defined models, we need to add the <module>/models folder and subfolders
  addpath(genpath(fullfile(extdir, 'models')));
  % In order to include user-defined functions, we need to add the <module>/functions folder and subfolders
  addpath(genpath(fullfile(extdir, 'functions')));
  % In order to include user-defined tests, we need to add the <module>/tests folder and subfolders
  addpath(genpath(fullfile(extdir, 'tests')));
  % In order to include user-defined tests, we need to add the <module>/tests folder and subfolders
  addpath(genpath(fullfile(extdir, 'pipelines')));
  % In order to include user-defined mex files, we need to add the <module>/src folder and subfolders
  addpath(genpath(fullfile(extdir, 'src')));
  
  % It might be useful to remove the VCS hidden folders, if any
  utils.helper.remove_cvs_from_matlabpath();
  utils.helper.remove_svn_from_matlabpath();
  utils.helper.remove_git_from_matlabpath();
  
  % get module name
  moduleInfo = utils.modules.moduleInfo(extdir);
  
  % locate the destination folder for the module .hash file
  hashFileName = sprintf('%s.hash', moduleInfo.name);
  
  % the hash file needs to go into the ltpda_toolbox/ltpda/.hash/ directory
  toolboxPath = fullfile(fileparts(which('ltpda_startup')), '..', '..');
  hashDir = fullfile(toolboxPath, '.hash');
  
  % First, check if the module is a released one:
  % search for the .hash file inside the module folder
  if ~isempty(dir(fullfile(extdir, hashFileName)))
    [success, message] = utils.modules.copyHashFile(hashFileName, extdir, hashDir);
  else
    % If the module is not a released one, it might be in Version Control by the user
    % So, try to create a hash of the module
    [success, message] = utils.modules.generateVCSHash(extdir, hashDir, hashFileName);
  end
  
  % If the hash for the module was not found nor produced, give up
  if ~success && ltpda_mode == utils.const.msg.DEBUG
    warning('Failed to deploy Version Control Identifier %s for module at %s into the LTPDA hash folder %s', ...
      hashFileName, extdir, hashDir);
  end
  
  res = installedClassMethods;
  
  if installedClassMethods
    fprintf('----------------------------------------------------------------\n');
    fprintf('   Additional class methods were installed. These will be  \n');
    fprintf('   available next time you run ''clear all'' or ''clear classes''.\n');
    fprintf('----------------------------------------------------------------\n');
  end
  
  % run init script
  init_script = sprintf('%s_init', moduleInfo.name);
  if exist(init_script, 'file')
    run(init_script);
  end
  
end

function method_names = checkClassContent(classname, directory)
  
  % Define class contents filename
  filename = 'Contents.m';
  
  % Open class contents filename
  fid = fopen(fullfile(directory, filename));
  
  if fid < 0
    utils.helper.msg(msg.IMPORTANT, ...
      'A problem happened opening the file %s', fullfile(directory, filename));
    S = {};
  else
    c = onCleanup(@() fclose(fid));
    % Read class contents filename
    try
      S = textscan(fid, '%s', 'delimiter', '\n', 'Headerlines', 2);
      S = S{1};
    catch ME
      utils.helper.msg(msg.IMPORTANT, ...
        'A problem happened scanning the file %s', fullfile(directory, filename));
      S = {};
    end
  end
  
  % Scan the contents for class_name/class_method pattern
  method_names = {};
  pat = '<a href="matlab:help\s(?<class>\w+)\/+(?<method>\w+)">';
  for jj = 1:numel(S)
    
    n = regexp(S{jj}, pat, 'names');
    
    if ~isempty(n)
      if ~strcmp(classname, n.class)
        error('### There is something wrong. I should work on class %s but I from the Content.m I read class %s', ...
          classname, n.class);
      else
        method_names = [method_names n.method];
      end
    end
  end
  
end

