% ALLXLABEL Set all the x-axis labels on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLXLABEL Set all the x-axis labels on the current figure.
%
% CALL:        allxlabel(label)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allxlabel(label)

  c = get(gcf, 'children');

  for k=1:length(c)

    t = get(c(k), 'Tag');
    if isempty(t)
      h = get(c(k), 'xlabel');
      set(h, 'string', label);
    end

  end

end

