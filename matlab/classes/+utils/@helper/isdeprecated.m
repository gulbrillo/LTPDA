% ISDEPRECATED attempts to determine if a given method of a class is
% deprecated.
%
% CALL
%              res = utils.helper.isdeprecated(className, methodName)
%
%
function out = isdeprecated(class, method)
  
  out = false;
  
  fname = which([class '.' method]);  
  if isempty(fname)
    return
  end
  
  filetext = fileread(fname);
  
  indicators = { ...
    'warning\(.*deprecated.*\)' ...
    'error\(.*deprecated.*\)' ...
    'warning\(.*deprecation.*\)' ...
    'error\(.*deprecation.*\)' ...
    };
  
  for kk=1:numel(indicators)    
    out = out | ~isempty(regexpi(filetext, indicators{kk}));
  end
  
end
% END
