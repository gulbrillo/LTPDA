% FROMSTRUCT sets all properties which are defined in the ltpda_uo class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the ltpda_uo class
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
  obj = fromStruct@ltpda_obj(obj, obj_struct);
  
  % Set 'name' object
  if isfield(obj_struct, 'name')
    obj.name = obj_struct.name;
  end
  
  % Set 'description' object
  if isfield(obj_struct, 'description')
    obj.description = obj_struct.description;
  end
  
  % Set 'UUID' object
  if isfield(obj_struct, 'UUID')
    obj.UUID = obj_struct.UUID;
  end
  
end
