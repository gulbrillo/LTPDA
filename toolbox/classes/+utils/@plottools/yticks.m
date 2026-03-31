% YTICKS set the input vector as the y-ticks of the current axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: YTICKS set the input vector as the y-ticks of the current
%              axis.
%
% CALL:        yticks(v)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yticks(v)

  set(gca, 'Ytick', v);

end

