% GPS2UTC converts GPS seconds to UTC time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GPS2UTC converts GPS seconds to UTC time.
%
% CALL:        UTC_time=GPS2UTC(GPS_time)
%
% FORMAT:      UTC time format: 'yyy-mm-dd- HH:MM:SS'
%              GPS time format: Seconds since 6. January 1980
%
%	EXAMPLES:    GPS_time=GPS2UTC(711129613)
%	             GPS_time='2002-07-19 16:00:00'
%
% HISTORY:     xx-xx-xxxx Karsten Koetter
%                 Creation
%              24-01-2007 M Hewitson.
%                 Maintained
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UTC_time = gps2utc(GPS_time)
  
  warning('This method is assuming a fixed number of leap seconds of 17.');

  leapSecond = 17; % Updated: 02.07.2015
  
  GPS_Epoch=datenum('01-06-1980 00:00:00')*86400;
  NUM_time=GPS_Epoch+GPS_time-leapSecond;

  UTC_time=datestr(NUM_time/86400,31);

end


