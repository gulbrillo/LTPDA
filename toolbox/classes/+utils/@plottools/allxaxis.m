% ALLXSCALE Set all the x scales on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLXAXIS Set all the xaxis ranges on the current figure.
%
% CALL:        allxaxis(x1, x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allxaxis(x1, x2)

  h = findobj(gcf, 'Type','axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'LTPDA_ANNOTATION');

  set(h, 'XLim', [x1 x2])

end

