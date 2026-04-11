% CAST - converts the numeric values in a data3D object to a new data type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAST - converts the numeric values in a data3D object to
%              a new data type depending on the axis.
%
% CALL:        obj.cast(type, axis)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cast(obj, type, axis)
  
  % Call super
  cast@data2D(obj, type, axis);
  
  if any(axis == 'z')
    obj.zaxis.cast(type);
  else
    % Don't do anything
  end
  
end
