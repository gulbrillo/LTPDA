% XAXIS Set the X axis range of the current figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XAXIS Set the X axis range of the current figure
%
% CALL:        xaxis(x1,x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xaxis(x1,x2)

  set(gca, 'XLim', [x1 x2]);

end

