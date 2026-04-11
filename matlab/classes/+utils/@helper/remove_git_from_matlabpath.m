% newpath = remove_git_from_matlabpath(oldpath)
%
% An utility function to remove .git folders from the given path
% If no output is provided, it will use and set the current Matlab path
% 
% M Hueller 03/09/2012 (code adapted from D Nicolodi)
%

function newpath = remove_git_from_matlabpath(oldpath)
  
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
    
    % get all folders in the path
    parts = regexp(p, filesep, 'split');
    
    % remove components if it contains a .git folder
    if ~any(strcmp('.git', parts))
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