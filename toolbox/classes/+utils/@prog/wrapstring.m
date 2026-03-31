function s = wrapstring(s, n)
% WRAPSTRING wraps a string to a cell array of strings with each cell less than n characters long.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WRAPSTRING wraps a string to a cell array of strings with each
%              cell less than n characters long.
%
% CALL:       s = wrapstring(s, n)
%
% INPUTS:     s  - String
%             n  - max length of each cell
%
% OUTPUTS:    s  - the wrapped cell string
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert to a cell if necessary
if ischar(s)
  s = [cellstr(s)];
end

% check it makes sense to proceed.
x = splitstring(s{end}, n);
if strcmp(char(x), char(s))
  return
end

% now keep splitting until we are happy.
while length(s{end}) >= n
  if length(s) > 1
    s1 = s(1:end-1);
  else
    s1 = [];
  end
  s2 = splitstring(s{end},n);
  if isempty(s2)
    break
  end
  s = [s1 s2];
end

%--------------------------------------------------------------------------
% split string at first ' ' or ','
function s = splitstring(s,n)


% disp(sprintf('- splitting %s', s))
fi = 0;
idx = find(s==' ' | s == ',' | s == '(' | s == '=');
if max(idx) > n
  for i=1:length(idx)
    if idx(i) > n & fi==0
      fi = i;
    end
  end
  j = idx(fi);
  s = [cellstr(strtrim(s(1:j))) cellstr(strtrim(s(j+1:end)))];
else
  s = [];
  return;
end
