% Returns the current system time as a GPS second.
%
% M Hewitson.
%
function gps = gpsnow()
  
  
  tz = java.util.TimeZone.getDefault();
  
  offset = tz.getOffset(double(time())) / 1000;
  daylightsaving = tz.getDSTSavings() / 1000;
  
  localtime = datestr(now,31);  
  gps = utils.timetools.utc2gps(localtime)-offset-daylightsaving;  
  
end
% END
