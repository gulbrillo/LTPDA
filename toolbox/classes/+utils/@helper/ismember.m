% ISMEMBER a simpler version that just checks if the given string(s) is/are in the
% given cell-array.
% 
%  res = ismember(string, cell2)
%  res = ismember(cell1, cell2)
%
% M Hewitson
%

function res = ismember(s, c)
  
  if ischar(s)
    res = any(strcmp(s, c));
  elseif iscell(s)
    res = false(size(s));
    for kk=1:numel(s)
      if any(strcmp(s{kk}, c))
        res(kk) = true;
      end
    end
  else
    error('### Only works for string or cell inputs.');    
  end
end