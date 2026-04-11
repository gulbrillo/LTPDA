% SETFS Set the property 'fs' to a filter object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'fs' of a filter object.
%
% CALL:        obj = obj.setFs(1.123);
%              obj = obj.setFs(plist('fs', 1.123));
%              obj = setFs(obj, 1.123);
%
% INPUTS:      obj - can be a vector, matrix, list, or a mix of them.
%              pl  - to set the frequency with a plist specify only one
%              plist with only one key-word 'fs'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setFs(obj, val)

  %%% decide whether we modify the ltpda_filter-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'fs'
  obj.fs = val;
end

