% UNINSTALLEXTENSIONSFORDIR uninstalls the toolbox extensions found under the
% given directory.
% 
% CALL: utils.modules.uninstallExtensionsForDir(dir)
% 
% 

function uninstallExtensionsForDir(varargin)

  extdir = varargin{1};
  
  if ~ischar(extdir)
    error('input a path to a directory of LTPDA extensions');
  end
  
  fprintf('* uninstalling extensions under %s ...\n', extdir);
  
  % toolbox path
  aopath = fileparts(which('ao'));
  parts = regexp(aopath, '@', 'split');
  classpath = parts{1};
  
  % for each user class, look for a corresponding directory and remove the
  % extension methods from.
  userclasses = utils.helper.ltpda_userclasses;
  for ucl = userclasses
    extsdir = fullfile(extdir, 'classes', ucl{1});
    if exist(extsdir, 'dir') == 7 
      fprintf('  uninstalling extensions for class %s ...\n', ucl{1});
      files = utils.prog.filescan(extsdir, '.m');      
      dstdir = fullfile(classpath, ['@' ucl{1}]);      
      for kk = 1:numel(files)
        f = files{kk};        
        [path, name, ext] = fileparts(f);        
        dstfile = fullfile(dstdir, [name ext]);
        fprintf('    uninstalling extension %s/%s ...\n', ucl{1}, [name ext]);
        delete(dstfile);
      end
    end
  end  
  
  % Remove any packages from the MATLAB path
  dirs = utils.prog.dirscan(extdir, '+');
  for kk = 1:numel(dirs)
    d = dirs{kk};
    disp(['  uninstalling package ' d]);
    fcnpaths = genpath(fullfile(extdir, d));
    rmpath(fcnpaths);  
  end
  
  % Remove subdirs to the MATLAB path
  rmpath(extdir);
  rmpath(fullfile(extdir, 'classes'));
  rmpath(genpath(fullfile(extdir, 'models')));
  rmpath(genpath(fullfile(extdir, 'functions')));
  rmpath(genpath(fullfile(extdir, 'tests')));
  rmpath(genpath(fullfile(extdir, 'pipelines')));
  rmpath(genpath(fullfile(extdir, 'src')));
  
  % Remove the .hash file
  % get module name
  moduleInfo = utils.modules.moduleInfo(extdir);
  hashFileName = sprintf('%s.hash', moduleInfo.name);
  
  % the hash file needs to go into the ltpda_toolbox/ltpda/.hash/ directory
  toolboxPath = fullfile(fileparts(which('ltpda_startup')), '..', '..');
  hashDir = fullfile(toolboxPath, '.hash');

  delete(fullfile(hashDir, hashFileName));
end


