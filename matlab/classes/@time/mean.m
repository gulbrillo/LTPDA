% MEAN return the mean time of an input time-object array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MEAN return the mean time of an input time-object array.
%              REMARK: This method returns a new time object, rounded to 1
%              ms
%
% CALL:        t = mean(T);
%
% IMPUTS:      T - array to time-objects.
%
% OUTPUTS:     t - time object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = mean(T)
  tm = mean([T(:).utc_epoch_milli]);
  t = time(tm / 1000);
end
