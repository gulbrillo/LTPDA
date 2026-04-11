% FORMAT Formats a time object into a string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: FORMAT(TIME, FRMT, TIMEZONE) Formats the time object TIME into a
% string, accordingly to the format descrption FRMT and the timezone TIMEZONE.
% 
% The FRMT format description can be a format number or a free form date format
% string, as accepted by the datestr() MATLAB function. The FRMT and TIMEZONE
% arguments are optional, if they are not specified or empty, the ones stored in
% the toolbox user preferences are used.
%
% EXAMPLES:
% 
%    >> t = time();
%    >> t.format();
%    >> t.format('yyyy-mm-dd HH:MM:SS.FFF z');
%    >> t.format('yyyy-mm-dd HH:MM:SS.FFF z', 'UTC');
%
% SEE ALSO: datestr time/strftime
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = format(tt, frmt, timezone)
  
  % check input arguments
  narginchk(1, 3);
  
  % second and third arguments are optional
  if nargin < 3
    timezone = '';
  end
  if nargin < 2
    frmt = '';
  end
  if isempty(tt)
    str = 'Not defined';
    return
  end

  % format all input time objects
  str = time.strftime(tt(1).utc_epoch_milli, frmt, timezone);
  for kk = 2:numel(tt)
    str = [ str ', ' time.strftime(tt(kk).utc_epoch_milli, frmt, timezone)];
  end
  
end

