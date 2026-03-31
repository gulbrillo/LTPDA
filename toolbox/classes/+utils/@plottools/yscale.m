% YSCALE Set the Y scale of the current axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: YSCALE Set the Y scale of the current axis
%
% CALL:        yscale('scale')         scale = 'lin' or 'log';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yscale(scale)

  set(gca, 'YScale', scale);
  
end

