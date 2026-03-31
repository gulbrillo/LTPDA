% ALLYAXIS Set all the yaxis ranges on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLYAXIS Set all the yaxis ranges on the current figure.
%
% CALL:        allyaxis(y1, y2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allyaxis(y1, y2)

  h = findobj(gcf, 'Type','axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'LTPDA_ANNOTATION');

  set(h, 'YLim', [y1 y2])

end

