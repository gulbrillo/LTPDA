% XSCALE Set the X scale of the current axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XSCALE Set the X scale of the current axis
%
% CALL:        xscale('scale')      scale = 'lin' or 'log';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xscale(scale)

  set(gca, 'XScale', scale);

end

