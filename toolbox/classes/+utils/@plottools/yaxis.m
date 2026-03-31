% YAXIS Set the Y axis range of the current figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: YAXIS Set the Y axis range of the current figure
%
% CALL:        yaxis(x1,x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yaxis(y1,y2)

  set(gca, 'YLim', [y1 y2]);

end

