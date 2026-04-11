% KEYS prints parameter list keys to the terminal.
% 
% CALL:
%          keys(class)
%          keys(class, method)
% 
% Examples:
% 
% >> keys('ao') % prints the keys for the ao constructor
% >> keys('ao', 'psd') % prints the keys for the ao/psd method
% 
% M Hewitson 
% 
% VERSION: $Id$
% 
function varargout = keys(varargin)
  
  className = varargin{1};
  if nargin > 1
    methodName = varargin{2};
  else
    methodName = className;
  end
  
  cmd = sprintf('%s.getInfo(''%s'')', className, methodName);
  ii = eval(cmd);
  
  out = '';
  for kk=1:numel(ii.sets)
    set = ii.sets{kk};
    
    pl = ii.plists(kk);
    keys = pl.getKeys();
    keyLine = '';
    keyLines = '';
    bannerLength = 0;
    for ll=1:numel(keys)
      key = keys{ll};
      keyLine = [keyLine key];
      if length(keyLine)>100
        keyLine = [keyLine sprintf('\n')];
        keyLines = [keyLines keyLine];
        bannerLength = max(bannerLength, length(keyLine));
        keyLine = '';
      else
        if ll < numel(keys)
          keyLine = [keyLine ', '];
        end
      end
    end    
    keyLines = [keyLines keyLine sprintf('\n')];
    
    bannerLength = max(bannerLength, length(keyLine));    
    
    setName = sprintf('    %s   \n', set);
    bannerLength = max(length(setName), bannerLength);
    banner = repmat('-', 1, bannerLength);
    
    out = [out banner sprintf('\n')];
    out = [out setName];    
    out = [out banner sprintf('\n')];
    
    
    out = [out keyLines sprintf('\n\n')];
    
  end
  
  disp(out);
  
  if nargout > 0
    varargout{1} = out;
  end
  
end
% END