% UTC2GPS Converts UTC time to GPS seconds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UTC2GPS Converts UTC time to GPS seconds.
%              UTC_time can also be an array of UTC times.
%
% CALL:        GPS_time=UTC2GPS(UTC_time)
%
% FORMAT:      UTC time format: 'yyy-mm-dd- HH:MM:SS'
%              GPS time format: Seconds since 6. January 1980
%
%	EXAMPLES:    GPS_time=UTC2GPS('2002-07-19 16:00:00')
%	             GPS_time=711129613
%
%	             GPS_time=UTC2GPS(['2002-07-19 16:00:00';'2001-07-19 16:00:00'])
%	             GPS_time=[711129613 ; 679593613]
%
% HISTORY:     xx-xx-xxxx Karsten Koetter
%                 Creation
%              24-01-2007 M Hewitson.
%                 Maintained
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GPS_time = utc2gps(UTC_time)
  
  warning('This method is assuming a fixed number of leap seconds of 17.');

  leapSecond = 17; % Updated: 02.07.2015
  
  GPS_Epoch=datenum('01-06-1980 00:00:00')*86400;

  [p q]=size(UTC_time);

  for i=1:p
    CurrUTC=UTC_time(i,:);
    % reformt string to stupid matlab format MM-DD-YYY
    CurrUTC=strcat(CurrUTC(6:10),'-',CurrUTC(1:4),CurrUTC(11:length(CurrUTC)));
    NUM_time=datenum(CurrUTC)*86400;

    GPS_time(i)=round(NUM_time-GPS_Epoch+leapSecond);
  end

end

