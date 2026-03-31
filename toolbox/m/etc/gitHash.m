% GITHASH reads and returns the git hash for this installation of LTPDA.
% 
% USAGE:
%         hash = gitHash(moduleName);
% 
%
function hash = gitHash()
  
  persistent hashCache;
  if isempty(hashCache)

    toolboxPath = fullfile(fileparts(which('ltpda_startup')), '..', '..');
    hashDir = fullfile(toolboxPath, '.hash');
    
    files = utils.prog.filescan(hashDir, '.hash');
    
    for kk=1:numel(files)
      hashFile = files{kk};           
      [path, name, ext] = fileparts(hashFile);
      fd = fopen(hashFile);
      if fd >= 0
        hashString = fscanf(fd, '%s');
        hashCache.(name) = hashString;
        fclose(fd);
      else
        error('Failed to read GIT hash file at %s', hashFile);
      end
    end
    
  end
  
  hash = hashCache;
  
end
% END