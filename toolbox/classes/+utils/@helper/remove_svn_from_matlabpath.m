% newpath = remove_svn_from_matlabpath(oldpath)
%
% An utility function to remove .svn folders from the given path
% If no output is provided, it will use and set the current Matlab path
% 
% D Nicolodi 25/03/2011
%

function newpath = remove_svn_from_matlabpath(oldpath)
  
  % if no path given load current matlab path
  if nargin < 1
    oldpath = matlabpath();
  end
  
  newpath = '';
  while true
    % split path definition into components
    [p, oldpath] = strtok(oldpath,pathsep);
    if isempty(p)
      break;
    end
    % remove components if it contais .svn
    if isempty(findstr(p,'.svn'))
      newpath = [newpath,pathsep,p];
    end
  end
  % remove initial pathsep
  newpath = newpath(2:end);
  
  % if no path given set the new path as the current one
  if nargin < 1
    path(newpath);
  end
  
end
