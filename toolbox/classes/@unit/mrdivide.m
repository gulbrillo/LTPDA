% MRDIVIDE implements mrdivide operator for unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MRDIVIDE implements mrdivide operator for unit objects.
%
% CALL:        a = a1/scalar
%              a = a1/a2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = mrdivide(v1,v2)

  v = rdivide(v1,v2);

end
