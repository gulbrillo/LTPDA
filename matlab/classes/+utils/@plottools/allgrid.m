% ALLGRID Set all the grids to 'state'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLGRID Set all the grids to 'state'
%
% CALL:        allgrid('state')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allgrid(state)

  if (strcmp(state,'on') || strcmp(state,'off'))

    c = get(gcf, 'children');

    for k=1:length(c)

      t = get(c(k), 'Tag');
      if t==''
        set(c(k), 'XGrid', state);
        set(c(k), 'YGrid', state);
      end

    end
  else
    error('state must be on or off');
  end

end

