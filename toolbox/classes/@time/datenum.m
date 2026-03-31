% DATENUM Converts a time object into MATLAB serial date representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Converts a time object into MATLAB serial date number.  A serial
% date number of 1 corresponds to Jan-01-0000.  The year 0000 is merely a
% reference point and is not intended to be interpreted as a real year.
% 
% NOTE: time objects formatting routines use the timezone specified in the LTPDA
% toolbox preferences, while MATLAB time routines always work in the local time
% zone, as specified by the operating system.  This conversion routine is built
% so that the time string representation obtained by time.format() and the one
% obtained from datestr(datenum(time)) are equivalent:
%
%   >> t1 = time();
%   >> datestr(datenum(t1)) === t1.format('dd-mmm-yyyy HH:MM:SS')
%
% However, except in the cases where the timezone is set to UTC in the LTPDA
% toolbox preferences, this implies that:
%
%   >> datenum(time()) ~= now()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function num = datenum(obj)
  
  % number of seconds since 1970-01-01 00:00:00.000 UTC
  num = double(obj);
  
  % take care of timezone offset
  num = num + time.timezone.getOffset(num * 1000)/1000;
  
  % divide by 60*60*24 to convert into days and add offset computed in local time
  num = num / 86400 + datenummx(1970,01,01,00,00,00);

  % NOTE: the MEX function datenummx() is used instead of the datenum() MATLAB
  % function to save time of the expensive input arguments checks performed by
  % the later

end

