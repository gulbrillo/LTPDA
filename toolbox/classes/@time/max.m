% MAX return the latest time of an input time-object array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAX return the latest time of an input time-object array.
%              REMARK: This method returns the pointer to the latest time
%                      and not a copy of the latest time.
%
% CALL:        t = max(T);
%
% IMPUTS:      T - array to time-objects.
%
% OUTPUTS:     t - time object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = max(T)
  [~, idx] = max([T(:).utc_epoch_milli]);
  t = T(idx);
end
