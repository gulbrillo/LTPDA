% FROMSTRUCT sets all properties which are defined in the ltpda_tf class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the ltpda_tf class
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
  obj = fromStruct@ltpda_uoh(obj, obj_struct);
  
  % Set 'iunits' object
  if isfield(obj_struct, 'iunits')
    obj.iunits = utils.helper.getObjectFromStruct(obj_struct.iunits);
  end
  
  % Set 'ounits' object
  if isfield(obj_struct, 'ounits')
    obj.ounits = utils.helper.getObjectFromStruct(obj_struct.ounits);
  end
  
end
