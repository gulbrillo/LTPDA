% REFORMAT_DATE reformats the input date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REFORMAT_DATE reformats the input date of the (preferred)
%              form 'yyyy-mm-dd HH:MM:SS' to the format 'mm-dd-yyyy HH:MM:SS'
%              which works with datenum.
%
% CALL:       s  = reformat_date(si)
%
% INPUTS:     si - date string in the format 'yyyy-mm-dd HH:MM:SS'
%
% OUTPUTS:    s  - date string in the format 'mm-dd-yyyy HH:MM:SS'
%
% EXAMPLE:    dnum = datenum(reformat_date('2007-05-04 22:34:22'));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = reformat_date (s)

  % reformt string to stupid matlab format MM-DD-YYY
  s=strcat(s(6:10),'-',s(1:4),s(11:length(s)));

end
