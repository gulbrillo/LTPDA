% DAYOFYEAR returns the day of year for the given time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: returns the day of year for the given time.
% 
%
%   >> doy = t.dayofyear;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function doy = dayofyear(obj)
  
  dn = obj.datenum;
  v = datevec(dn);  
  doy = floor(dn - datenum(v(1), 1, 1)) + 1;

end
% END