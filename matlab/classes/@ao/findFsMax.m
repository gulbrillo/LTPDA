% findFsMax Returns the max Fs of a set of AOs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns the max Fs of a set of AOs
%
% CALL:        fsmax = findFsMax(as)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fs = findFsMax(as)

  fs = 0;
  for jj=1:numel(as)
    d = as(jj).data;
    if d.isprop('fs')
      if d.fs > fs
        fs = d.fs;
      end
    end
  end

end

