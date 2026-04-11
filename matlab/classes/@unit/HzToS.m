% HZTOS convert any 'Hz' units to 's'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HZTOS convert any 'Hz' units to 's'.
%
% CALL:        a = a.HzToS()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function HzToS(u)
  
  idx = strcmp(u.strs, 'Hz');
  u.strs(idx) = {'s'};
  u.exps(idx) = -u.exps(idx);  
  u.vals(idx) = -u.vals(idx);  
  
end
