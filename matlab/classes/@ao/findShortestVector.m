% findShortestVector Returns the length of the shortest vector in samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns the length of the shortest vector in samples
%
% CALL:        lmin = findShortestVector(as)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lmin = findShortestVector(as)

  lmin = 1e20;
  for jj=1:numel(as)
    len_as = len(as(jj));
    if len_as < lmin
      lmin = len_as;
    end
  end

end

