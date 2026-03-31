% taken verbatim from 'datestr.m' in MATLAB R2008b

function formatstr = getdateform(dateform)
  % determine date format string from date format index.
  switch dateform
      case -1, formatstr = 'dd-mmm-yyyy HH:MM:SS';
      case 0,  formatstr = 'dd-mmm-yyyy HH:MM:SS';
      case 1,  formatstr = 'dd-mmm-yyyy';
      case 2,  formatstr = 'mm/dd/yy';
      case 3,  formatstr = 'mmm';
      case 4,  formatstr = 'm';
      case 5,  formatstr = 'mm';
      case 6,  formatstr = 'mm/dd';
      case 7,  formatstr = 'dd';
      case 8,  formatstr = 'ddd';
      case 9,  formatstr = 'd';
      case 10, formatstr = 'yyyy';
      case 11, formatstr = 'yy';
      case 12, formatstr = 'mmmyy';
      case 13, formatstr = 'HH:MM:SS';
      case 14, formatstr = 'HH:MM:SS PM';
      case 15, formatstr = 'HH:MM';
      case 16, formatstr = 'HH:MM PM';
      case 17, formatstr = 'QQ-YY';
      case 18, formatstr = 'QQ';
      case 19, formatstr = 'dd/mm';
      case 20, formatstr = 'dd/mm/yy';
      case 21, formatstr = 'mmm.dd,yyyy HH:MM:SS';
      case 22, formatstr = 'mmm.dd,yyyy';
      case 23, formatstr = 'mm/dd/yyyy';
      case 24, formatstr = 'dd/mm/yyyy';
      case 25, formatstr = 'yy/mm/dd';
      case 26, formatstr = 'yyyy/mm/dd';
      case 27, formatstr = 'QQ-YYYY';
      case 28, formatstr = 'mmmyyyy'; 
      case 29, formatstr = 'yyyy-mm-dd';
      case 30, formatstr = 'yyyymmddTHHMMSS';
      case 31, formatstr = 'yyyy-mm-dd HH:MM:SS';
      otherwise
          error('MATLAB:datestr:DateNumber',...
                'Unknown date format number: %s', dateform);
  end
end

