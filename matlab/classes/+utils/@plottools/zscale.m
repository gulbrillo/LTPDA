% ZSCALE Set the Z scale of the current axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ZSCALE Set the Z scale of the current axis
%
% CALL:        zscale('scale')   scale = 'lin' or 'log';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zscale(scale)

  set(gca, 'ZScale', scale);

end

