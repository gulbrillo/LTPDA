% FILESCAN recursively scans the given directory for files that end in 'ext'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILESCAN recursively scans the given directory for files
%              that end in 'ext' and returns a list of the full paths.
%
% CALL:       files = filescan(root_dir, ext)
%
% INPUTS:     root_dir - directory
%             ext      - extension of a file (or cell-array of extensions)
%
% OUTPUTS:    files    - the found file names
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function files = filescan(root_dir, ext)
  files = getfiles(root_dir, ext, []);
end

%--------------------------------------------------------------------------
function ofiles = getfiles(root_dir, iext, ofiles)
  % Recursive function for getting file lists
  %

  files = dir(root_dir);

  for j=1:length(files)
    if files(j).isdir
      if strcmp(files(j).name,'.')==0 && strcmp(files(j).name,'..')==0
        ofiles = getfiles([root_dir '/' files(j).name], iext, ofiles);
      end
    else
      parts = regexp(files(j).name, '\.', 'split');
      ext = ['.' parts{end}];
      if any(strcmp(ext, iext))
        ofiles = [ofiles; {[root_dir '/' files(j).name]}];
      end
    end
  end
end
% END