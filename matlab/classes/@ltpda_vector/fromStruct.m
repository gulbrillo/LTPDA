% FROMSTRUCT sets all properties which are defined in the ltpda_vector class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the ltpda_vector class
%              from the structure to the input object.
%
% REMARK:      Abstract classes handle only one input object and a
%              structure with the size 1.
%
% CALL:        obj = fromStruct(obj, struct)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromStruct(obj, obj_struct)
  
  % Call super-class
  obj = fromStruct@ltpda_nuo(obj, obj_struct);
  
  % Set 'units' object
  if isfield(obj_struct, 'units')
    obj.units = utils.helper.getObjectFromStruct(obj_struct.units);
  end
  
  % Set 'data' object
  if isfield(obj_struct, 'data')
    obj.data = obj_struct.data;
  end
  
  % Set 'ddata' object
  if isfield(obj_struct, 'ddata')
    obj.ddata = obj_struct.ddata;
  end
  
  % Set 'name'
  if isfield(obj_struct, 'name')
    obj.name = obj_struct.name;
  end
  
  
end
