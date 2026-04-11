% FROMDATAFILE Default method to convert a data-file into a ltpda_uoh-object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDatafile
%
% DESCRIPTION: Default method to convert a data-file into a ltpda_uoh-object
%
% CALL:        obj = fromDatafile(obj, pli)
%
% PARAMETER:   obj: empty ltpda_uoh-object
%              pli: plist-object (must contain the filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromDatafile(obj, pli)

  error('### It is not possible to convert this data file into a %s-object', class(obj));

end
