% newpath = remove_cvs_from_matlabpath(oldpath)
%
% An utility function to remove CVS folders from the given path
% If no output is provided, it will use and set the current Matlab path
% 
% D Nicolodi 25/03/2011
%

function newpath = remove_cvs_from_matlabpath(oldpath)

  % if a path is not given load current matlab path
  if nargin < 1
    oldpath = matlabpath();
  end
  
  newpath = '';
  while true
    % split path definition into components
    [p, oldpath] = strtok(oldpath, pathsep);
    if isempty(p)
      break;
    end
    
    % remove components if it ends with CVS
    [dummy, name] = fileparts(p);
    if ~strcmp(name, 'CVS')
      newpath = [newpath, pathsep, p];
    end
  end
  
  % remove initial pathsep
  newpath = newpath(2:end);
  
  % if a path was not given save the new path
  if nargin < 1
    path(newpath);
  end
  
end
