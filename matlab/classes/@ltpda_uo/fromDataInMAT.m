% FROMDATAINMAT Default method to convert a data-array into am ltpda_uoh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDataInMAT
%
% DESCRIPTION: Convert a saved data-array into an AO with a tsdata-object
%
% CALL:        obj = fromDataInMAT(obj, data-array, plist)
%
% PARAMETER:   data-array: data-array
%              plist:      plist-object (must contain the filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromDataInMAT(obj, data, pli)

  error('### This mat-file doesn''t contain a %s-object', class(obj));

end
