% PLUS implements addition operator for unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLUS implements addition operator for two unit objects.
%
% CALL:        a = a1+scalar
%              a = a1+a2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = plus(v1,v2)

  if ~isequal(v1, v2)
    error('### Can''t add different units');
  end

  v = v1;

end
