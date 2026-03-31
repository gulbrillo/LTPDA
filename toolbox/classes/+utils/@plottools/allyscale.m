% ALLYSCALE Set all the Y scales on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLYSCALE Set all the Y scales on the current figure.
%
% CALL:        allyscale(scale)         scale = 'lin' or 'log';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allyscale(scale)

  c = get(gcf, 'children');

  if ~(strcmpi(scale, 'lin') || (strcmpi(scale, 'log')))
    error('### please use ''lin'' or ''log'' as an input.')
  end

  for k=1:length(c)

    t = get(c(k), 'Tag');
    if isempty(t)
      set(c(k), 'YScale', scale);
    end

  end

end

