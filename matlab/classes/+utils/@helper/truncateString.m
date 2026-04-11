% TRUNCATESTRING truncates a string or cell-array of strings to a given number of characters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TRUNCATESTRING truncates a string or cell-array of strings
%              to a given number of characters.
%
% CALL:        string = utils.helper.truncateString(string, num)
%
% PERAMETERS:  string: String or cell array of strings
%              num:    Number of characters you want to truncate to
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = truncateString(str, num)
  
  if iscellstr(str)
    str = cellfun(@(s) s(1:min(length(s), num)), str, 'UniformOutput', false);
  elseif ischar(str)
    str = str(1:min(length(str), num));
  end
  
end
