% STOHZ convert any 's' units to 'Hz'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STOHZ convert any 's' units to 'Hz'.
%
% CALL:        a = a.sToHz()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sToHz(u)
  
  idx = strcmp(u.strs, 's');
  u.strs(idx) = {'Hz'};
  u.exps(idx) = -u.exps(idx);  
  u.vals(idx) = -u.vals(idx);  
  
end
