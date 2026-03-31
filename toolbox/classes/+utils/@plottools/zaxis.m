% ZAXIS Set the Z axis range of the current figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ZAXIS Set the Z axis range of the current figure
%
% CALL:        zaxis(x1,x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zaxis(x1,x2)

  set(gca, 'ZLim', [x1 x2]);

end

