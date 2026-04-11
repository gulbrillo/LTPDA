% CAST - converts the numeric values in a data2D object to a new data type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAST - converts the numeric values in a data2D object to
%              a new data type depending on the axis.
%
% CALL:        obj.cast(type, axis)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cast(obj, type, axis)
  
  % Call super
  cast@ltpda_data(obj, type, axis);
  
  if any(axis == 'x')
    obj.xaxis.cast(type);
  else
    % Don't do anything
  end
  
end
