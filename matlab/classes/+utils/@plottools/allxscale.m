% ALLXSCALE Set all the x scales on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLXSCALE Set all the x scales on the current figure.
%
% CALL:        allxscale(scale)     scale = 'lin' or 'log';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allxscale(scale)

  c = get(gcf, 'children');

  if ~(strcmpi(scale, 'lin') || (strcmpi(scale, 'log')))
    error('### please use ''lin'' or ''log'' as an input.')
  end

  for k=1:length(c)

    t = get(c(k), 'Tag');
    if isempty(t)
      set(c(k), 'XScale', scale);
    end

  end

end

