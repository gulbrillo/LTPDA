% POWER implements power operator for unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: POWER implements power operator for unit objects.
%
% CALL:        a = a1.^scalar
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = power(vi, exp)
  v = copy(vi, 1);
  if ~isnumeric(exp)
    error('### Can only raise units to a numeric power.');
  end  
  v.exps = v.exps*exp;
  
end
