% DIRSCAN recursively scans the given directory for subdirectories that match the given pattern.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DIRSCAN recursively scans the given directory for subdirectories that
% match the given pattern.
%
% CALL:       files = dirscan(root_dir, pattern)
%
% INPUTS:     root_dir - directory
%             pattern  - regexp pattern to match
%
% OUTPUTS:    dirs    - the found directory names
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dirs = dirscan(root_dir, pattern)
  dirs = getdirs(root_dir, pattern, []);
end

%--------------------------------------------------------------------------
function odirs = getdirs(root_dir, pattern, odirs)
  % Recursive function for getting file lists
  %

  files = dir(root_dir);

  for j=1:length(files)
    if files(j).isdir
      
      % add this dir if the pattern matches
      if ~isempty(regexp(files(j).name, pattern, 'match'))
        odirs = [odirs {fullfile(root_dir, files(j).name)}];
      end    
      % and look inside
      if strcmp(files(j).name,'.')==0 && strcmp(files(j).name,'..')==0
        odirs = getdirs(fullfile(root_dir, files(j).name), pattern, odirs);
      end
      
    end
  end
end
% END