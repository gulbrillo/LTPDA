% CALENDARWEEK returns the ISO week of the year for the given time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Returns the week of the year for the given time based on the
% ISO week calendar standard. The first week of a year is the week that 
% contains the first Thursday of the year and begins the previous Monday. 
% A year can therefore have 52 or 53 weeks and the last few days of a year
% can fall within the first week of the following year.
%
%   >> woy = t.calendarweek;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function woy = calendarweek(obj)

  dn = obj.datenum;
  dv = datevec(dn);

  % Find the first Thursday of the year to define week 1 by cycling from
  % the 1st of Jan.
  for ii = 1:7
    % weekday returns a number representation for the day of the week a 
    % particular date fell. Sunday = 1, Monday = 2 ... Saturday = 7.
    checkDayOfWeek = weekday(datenum(dv(1), 1, ii));
    if checkDayOfWeek == 5
      % Plus 3 to account for week starting on Monday rather than the
      % Thursday.
      daysSinceFirstWeek = (floor(dn - datenum(dv(1), 1, 1)) + 1) - ii + 3;
      break;
    end
  end

  % If the day falls before the first week of the year it is in the final
  % week of previous year. Therefore call weekofyear recursively with last 
  % day of previous year.
  if daysSinceFirstWeek < 0
    woy = calendarweek(time([num2str(dv(1)-1) '-12-31']));
  else
    woy = floor(daysSinceFirstWeek/7) + 1;    
  end
  
  % Check the edge case where last few days of year can be in first week of
  % following year.
  if woy == 53    
    checkNextYear = weekday(datenum(dv(1)+1, 1, 1));    
    if checkNextYear == 2 || checkNextYear == 3 || checkNextYear == 4 || checkNextYear == 5
      woy = 1;
    end    
  end  

end
% END

