% MODE return the mode time of an input time-object array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MODE return the mode time of an input time-object array.
%              REMARK: This method returns the pointer to the mode time
%                      and not a copy of the mode time.
%
% CALL:        t = mode(T);
%
% IMPUTS:      T - array to time-objects.
%
% OUTPUTS:     t - time object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = mode(T)
  tm = mode([T(:).utc_epoch_milli]);
  t = time(plist('milliseconds', tm));
end
