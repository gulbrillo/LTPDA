% SETVALS set the vals field of the unit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETVALS set the vals field of the unit.
%
% CALL:        a = a.setVals(vals)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function u = setVals(u, v)
  
  if numel(v) ~= numel(u.vals)
    error('### Can''t change the number of elements in <vals>.');
  end
  
  u.vals = v;
  
end
