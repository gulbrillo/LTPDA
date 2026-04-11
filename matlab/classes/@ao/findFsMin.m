% findFsMin Returns the min Fs of a set of AOs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns the min Fs of a set of AOs
%
% CALL:        fsmin = findFsMin(as)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fs = findFsMin(as)

  fs = realmax;
  for jj=1:numel(as)
    d = as(jj).data;
    if d.isprop('fs')
      if d.fs < fs
        fs = d.fs;
      end
    end
  end

end

