% XTICKS set the input vector as the x-ticks of the current axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XTICKS set the input vector as the x-ticks of the current
%              axis.
%
% CALL:        xticks(v)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xticks(v)

  set(gca, 'Xtick', v);

end

