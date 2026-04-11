% FROMSTRUCT sets all properties which are defined in the data2D class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the data2D class
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
  obj = fromStruct@ltpda_data(obj, obj_struct);
  
  % Set 'xaxis' object
  if isfield(obj_struct, 'xaxis')
    obj.xaxis = utils.helper.getObjectFromStruct(obj_struct.xaxis);
  end
  
end
