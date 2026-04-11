% FROMLISO Default method to read LISO files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromLISO
%
% DESCRIPTION: If a class can not handle a LISO file then throw always an error.
%              If a class can handle thie file then overload this method.
%
% CALL:        f = fromLISO(f, pli)
%
% PARAMETER:   pzm: Empty ltpda_uoh-object
%              pli: input plist (must contain the filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromLISO(obj, pli)

  error('### It is not possible to convert a LISO file into a %s-object', class(obj));

end
