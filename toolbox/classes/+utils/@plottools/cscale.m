% CSCALE Set the color range of the current figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CSCALE Set the color range of the current figure
%
% CALL:        cscale(x1,x2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cscale(y1,y2)

  set(gca, 'CLim', [y1 y2]);

  h = get(gcf, 'Children');

  for j=1:length(h)
    if strcmp(get(h(j), 'Tag'), 'Colorbar')==1
      colorbar;
    end
  end

end

