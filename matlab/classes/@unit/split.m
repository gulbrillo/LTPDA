% SPLIT split a unit into a set of single units.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPLIT split a unit into a set of single units.
%
% CALL:        units = split(unit)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function us = split(u)
 
  us = [];
  for kk=1:numel(u.strs)    
    nu = unit;
    nu.strs = u.strs(kk);
    nu.exps = u.exps(kk);
    nu.vals = u.vals(kk);
    us = [us nu];    
  end  
  
end
