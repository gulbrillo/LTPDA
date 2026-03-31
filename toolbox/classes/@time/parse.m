function msec = parse(str, format, timezone)
  
  persistent allZoneStrings;
  
  % second and third arguments are optional
  if nargin < 3
    timezone = '';
  end
  if nargin < 2
    format = '';
  end
  
  % default timezone
  if isempty(timezone)
    timezone = time.timezone;
  end
  % convert string timezone into java object
  if ischar(timezone)
    
    if isempty(allZoneStrings)
      % Cell array with:
      % allZoneStrings{i, 1} - time zone ID
      % allZoneStrings{i, 2} - long name of zone in standard time
      % allZoneStrings{i, 3} - short name of zone in standard time
      % allZoneStrings{i, 4} - long name of zone in daylight saving time
      % allZoneStrings{i, 5} - short name of zone in daylight saving time
      allZoneStrings = cell(java.text.DateFormatSymbols.getInstance.getZoneStrings());
    end
    
    % Check if the user have used one of the short name of zone in daylight
    % saving time. These are not supported as time zone IDs e.g. 'CEST'
    % Map these short names to the correct time zone ID (map to columns 1)
    idx = find(strcmp(allZoneStrings(:, 5), timezone));
    if any(idx)
      timezone = allZoneStrings{idx(1), 1};
    end
    
    % Check if the ID is supported.
    if any(strcmp(allZoneStrings(:,1), timezone)) || ~isempty( regexp(timezone, '^GMT[+-]\d\d?(:?\d\d)?$', 'once') )
      timezone = java.util.TimeZone.getTimeZone(timezone);
    else
      error('### Unable to parse the time zone [%s].\nUse the command <strong>java.util.TimeZone.getAvailableIDs()</strong> to get all supported IDs.', timezone);
    end
  end
  
  % obtain a java time format description to use for parsing
  if isempty(format)
    % infer it from the string
    format = parse_time_string(str);
  else
    % convert a given MATLAB time format into a Java one
    format = time.matfrmt2javafrmt(format);
  end
  
  % parse the string accordingly to the corrent format and timezone
  tformat = java.text.SimpleDateFormat(format);
  tformat.setTimeZone(timezone);
  try
    % It is necessary to replace 'GMT+03' by 'GMT+03:00' because java
    % expects the ':00' at the end.
    str = regexprep(str, '([gG][mM][tT][+-]\d\d?$)', '$1:00');
    msec = tformat.parse(str).getTime();
  catch
    error('### unable to parse time string ''%s'' accordingly to format ''%s''', str, format);
  end
  
end


function str = parse_time_string(str)
  
  % supported patterns
  parse = { '\s[gG][mM][tT][+-]?\d\d?$',      ' z';      ... % GMT+1 or GMT+12
    '\s[gG][mM][tT][+-]?\d\d?:\d\d$', ' z';      ... % GMT+08:12
    '\s\w{3}$',                       ' z';      ... % PST
    '\s\w{4}$',                       ' z';      ... % Cuba, Eire, GMT0, Zulu, Iran, W-SU
    '\s[+-]\d{4}$',                   ' Z';      ... % +0800
    '\d{2}:\d{2}:\d{2}',              'HH:mm:ss';    ...
    '^\d{2}:\d{2}',                   'mm:ss';       ...
    '\d{2}:\d{2}',                    'HH:mm';       ...
    '\d{2} \w{3} \d{4}',              'dd MMM yyyy'; ...
    '\d{2}-\w{3}-\d{4}',              'dd-MMM-yyyy'; ...
    '\d{2}.\w{3}.\d{4}',              'dd.MMM.yyyy'; ...
    '\d{4} \w{3} \d{2}',              'yyyy MMM dd'; ...
    '\d{4}-\w{3}-\d{2}',              'yyyy-MMM-dd'; ...
    '\d{4}.\w{3}.\d{2}',              'yyyy.MMM.dd'; ...
    '\d{2}/\d{2}/\d{4}',              'dd/MM/yyyy';  ...
    '\d{2}-\d{2}-\d{4}',              'dd-MM-yyyy';  ...
    '\d{2}\.\d{2}\.\d{4}',            'dd.MM.yyyy';  ...
    '\d{4}/\d{2}/\d{2}',              'yyyy/MM/dd';  ...
    '\d{4}-\d{2}-\d{2}',              'yyyy-MM-dd';  ...
    '\d{4}\.\d{2}\.\d{2}',            'yyyy.MM.dd';  ...
    '\d{2}-\d{3}',                    'yy-ddd'; ...
    '\d{2}-\d{2}',                    'MM-dd';       ...
    '\.\d{1,3}',                      '.SSS'};
  
  % try to match the patterns to the string and replace
  % it with the corresponding Java time format descriptor
  re   = parse(:,1);
  frmt = parse(:,2);
  str  = regexprep(str, re, frmt);
  
end
