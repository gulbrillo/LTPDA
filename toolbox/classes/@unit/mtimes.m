% MTIMES implements mtimes operator for unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MTIMES implements mtimes operator for unit objects.
%
% CALL:        a = a1*scalar
%              a = a1*a2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = mtimes(v1,v2)

  v = times(v1,v2);

end
