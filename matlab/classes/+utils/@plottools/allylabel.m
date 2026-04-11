% ALLYLABEL Set all the y-axis labels on the current figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLYLABEL Set all the y-axis labels on the current figure.
%
% CALL:        allylabel(label)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allylabel(label)

  c = get(gcf, 'children');

  for k=1:length(c)

    t = get(c(k), 'Tag');
    if isempty(t)
      h = get(c(k), 'ylabel');
      set(h, 'string', label);
    end

  end

end

