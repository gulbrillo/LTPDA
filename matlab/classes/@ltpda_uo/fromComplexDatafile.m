% FROMCOMPLEXDATAFILE Default method to convert a complex data-file into a ltpda_uoh-object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromComplexDatafile
%
% DESCRIPTION: Default method to convert a complex data-file into a
%              ltpda_uoh-object
%
% CALL:        obj = fromComplexDatafile(obj, pli)
%
% PARAMETER:   obj: empty ltpda_uoh-object
%              pli: plist-object (must contain the filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromComplexDatafile(obj, pli)

  error('### It is not possible to convert this complex data file into a %s-object', class(obj));

end
