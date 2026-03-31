% STRFTIME Formats a time expressed as msec since the epoch into a string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRFTIME(MSEC, FRMT, TIMEZONE) Formats the time MSEC, expressed
% as milliseconds since the unix epoch, 1970-01-01 00:00:00.000 UTC, into a
% string, accordingly to the format descrption FRMT and the timezone TIMEZONE.
%
% The FRMT format description can be a format number or a free form date format
% string, as accepted by the datestr() MATLAB function. The FRMT and TIMEZONE
% arguments are optional, if they are not specified or empty, the ones stored in
% the toolbox user preferences are used.
%
% EXAMPLES:
%
%    >> msec = time.now();
%    >> str = time.strftime(msec);
%    >> str = time.strftime(msec, 'yyyy-mm-dd HH:MM:SS.FFF z');
%    >> str = time.strftime(msec, 'yyyy-mm-dd HH:MM:SS.FFF z', 'UTC');
%
% SEE ALSO: datestr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = strftime(msec, frmt, timezone)
  
  % check input arguments
  narginchk(1, 3);
  
  % second and third arguments are optional
  if nargin < 3
    timezone = time.timezone;
  end
  if nargin < 2
    frmt = time.timeformat;
  end
  
  % check timezone
  if isempty(timezone)
    timezone = time.timezone;
  end
  % check frmt
  if isempty(frmt)
    frmt = time.timeformat;
  end
  
  % In the case of NaN, just set the output to 'NaN'
  if isnan(msec)
    str = 'NaN';
    return
  end
  
  % convert string timezone into java object
  if ischar(timezone)
    timezone = java.util.TimeZone.getTimeZone(timezone);
  end
  
  % convert matlab time formatting specification string into a java one
  frmt = time.matfrmt2javafrmt(frmt);
  
  % format
  tformat = java.text.SimpleDateFormat(frmt);
  tformat.setTimeZone(timezone);
  str = char(tformat.format(msec));
  
end

