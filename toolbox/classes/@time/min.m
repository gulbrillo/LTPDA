% MIN return the earliest time of an input time-object array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MIN return the earliest time of an input time-object array.
%              REMARK: This method returns the pointer to the earliest time
%                      and not a copy of the earliest time.
%
% CALL:        t = min(T);
%
% IMPUTS:      T - array to time-objects.
%
% OUTPUTS:     t - time object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = min(T)
  [~, idx] = min([T(:).utc_epoch_milli]);
  t = T(idx);
end
