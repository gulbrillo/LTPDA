% CREATEDOCUMENTATION create LTPDA documentation
%
% CALL:
%         createDocumentation(pl)
%
% plist keys:
%        pass true or false for these keys:
%                  'toc'  - build table of contents
%                'class'  - build class descriptions
%                 'func'  - create functions by category
%
%
function createDocumentation(varargin)
  
  
  buildTOC   = false;
  buildClass = false;
  buildFunc  = false;
  
  if nargin > 0
    if isa(varargin{1}, 'plist')
      pl = varargin{1};
      if pl.isparam('toc')
        buildTOC = pl.find('toc');
      end
      if pl.isparam('class')
        buildClass = pl.find('class');
      end
      if pl.isparam('func')
        buildFunc = pl.find('func');
      end
      throwErrorOnExtensions = pl.find('throwErrorOnExtensions');
      if isempty(throwErrorOnExtensions)
        throwErrorOnExtensions = true;
      end
    end
  end
  
  % Check if we have installed extenstion packages.
  % If so then the user who wants to build the documentation 
  % should remove the extensions.
  prefs = getappdata(0, 'LTPDApreferences');
  extenstions = prefs.getExtensionsPrefs.getSearchPaths();
  if ~extenstions.isEmpty() && throwErrorOnExtensions
    error('### If you want to build the documentation for a release then should you remove the extensions before you build the documentation. Otherwise add [settings.throwErrorOnExtensions = false] to your makeToolbox config.');
  end
  
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Create site map file                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create the documentation for the site map
  if buildTOC
    createContentFile.convertTOC
  end
  
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Create class description                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if buildClass
    createClassDesc.create_main_class_desc()
    createClassDesc.create_class_desc()
  end
  
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Create function by category                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if buildFunc
    createFuncByCat.mkMain()
  end
  
  %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %             Create complete HTML files from the content files             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  try
    
    fprintf('\n  - Creating documentation from helptoc.xml: ')
    
    [~, pythonVer] = system('python -V');
    
    % Scan for the first two version numbers in 'Python 2.6.5'
    pythonVer = sscanf(pythonVer, '%*s%d.%d');
    if isempty(pythonVer) && numel(pythonVer) ~= 2
      error('### Failed check of Python version');
    end
    pythonVer   = [1 .1] * pythonVer;
    
    % move to the path of the helptoc.xml files
    helptocPath = createContentFile.getAbsPathToHelp();
    currPath = pwd;
    cd(helptocPath);
    
    % Define python script name and helptoc filename
    if pythonVer > 2.6
      pyFile = 'mkhelpfiles_v3.py';
    else
      pyFile = 'mkhelpfiles.py';
    end
    helptocFile = 'helptoc.xml';
    
    % Execute python script
    cmd = sprintf('python %s -i %s', pyFile, helptocFile);
    [status,result] = system(cmd);
    if status ~= 0
      error('### Can not execute the python script.\n%s', result);
    end
    
    % Go back to the last path
    cd(currPath);
    
  catch ME
    warning('!!! Couldn''t run mkhelpfiles.py. Do you have python installed?');
  end
  
  fprintf('finished.\n\n');
  
end



