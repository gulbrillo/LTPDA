% CAST - converts the numeric values in a ltpda_data object to a new data type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAST - converts the numeric values in a ltpda_data object to
%              a new data type depending on the axis.
%
% CALL:        obj.cast(type, axis)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cast(obj, type, axis)
  
  if any(axis == 'y')
    obj.yaxis.cast(type);
  else
    % Don't do anything
  end
  
end
