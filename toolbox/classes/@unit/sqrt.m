% SQRT computes the square root of an unit object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SQRT computes the square root of an unit object.
%
% CALL:        u_out = sqrt(i_in);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = sqrt(vi)
  v = copy(vi, 1);
  v.exps = v.exps*0.5;
end
