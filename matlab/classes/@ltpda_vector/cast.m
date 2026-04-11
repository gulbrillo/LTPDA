% CAST - converts the numeric values in a ltpda_vector object to a new data type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAST - converts the numeric values in a ltpda_vector object
%              to a new data type.
%
% CALL:        obj.cast(type)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cast(obj, type)
  
  obj.data  = cast(obj.data, type);
  obj.ddata = cast(obj.ddata, type);
  
end
