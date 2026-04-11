% FROMSTRUCT sets all properties which are defined in the data3D class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the data3D class
%              from the structure to the input object.
%
% REMARK:      Abstract classes handle only one input object and a
%              structure with the size 1.
%
% CALL:        obj = fromStruct(obj, struct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromStruct(obj, obj_struct)
  
  % Call super-class
  obj = fromStruct@data2D(obj, obj_struct);
  
  % Set 'zaxis' object
  if isfield(obj_struct, 'zaxis')
    obj.zaxis = utils.helper.getObjectFromStruct(obj_struct.zaxis);
  end
  
end
