% DISPLAYMETHODINFO displays the information about a method in the MATLAB browser.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISPLAYMETHODINFO displays the information about a method
%              in the MATLAB browser.
%
% CALL:        displayMethodInfo(className, methodName)
%              displayMethodInfo(minfo)
%
% INPUTS:       className: String of the class.  For example 'ao'
%              methodName: String of the method. For example 'sin'
%                   minfo: an minfo object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = displayMethodInfo(varargin)
  
  % Check the inputs
  if nargin == 1 && isa(varargin{1}, 'minfo')
    m = varargin{1};
  else
    if nargin ~= 2
      error('### Unknown number of inputs');
    elseif ~ischar(varargin{1}) && ~ischar(varargin{2})
      error('### The inputs must be a class name and method name (both Strings)');
    end
    
    className = varargin{1};
    methodName = varargin{2};
    
    % Get method info object.
    m = feval(sprintf('%s.getInfo', className), methodName);
  end
  
  % 
  txt = m.tohtml;
  
  % Workaround for the broken anchor tags in the HTML page.
  % It is necessary to write the HTML page to disk.
  className = m.mclass;
  if isempty(className)
    className = 'unknown';
  end
  dynamicHelpPath = fullfile(prefdir(), 'dynamicHelp', className);
  
  if ~exist(dynamicHelpPath, 'dir')
    mkdir(dynamicHelpPath);
  end

  filename = sprintf('%s.html', m.mname);
  
  file = fullfile(dynamicHelpPath, filename);
  
  fid = fopen(file, 'w');
  fwrite(fid, txt, 'char');
  fclose(fid);
  
  web(file, '-new', '-noaddressbox');
  
  varargout = {};
  
end
