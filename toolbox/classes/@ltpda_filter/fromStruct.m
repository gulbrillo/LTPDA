% FROMSTRUCT sets all properties which are defined in the ltpda_filter class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the ltpda_filter class
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
  obj = fromStruct@ltpda_tf(obj, obj_struct);
  
  % Set 'fs' object
  if isfield(obj_struct, 'fs')
    obj.fs = obj_struct.fs;
  end
  
  % Set 'infile' object
  if isfield(obj_struct, 'infile')
    obj.infile = obj_struct.infile;
  end
  
  % Set 'a' object
  if isfield(obj_struct, 'a')
    obj.a = obj_struct.a;
  end
  
  % Set 'histout' object
  if isfield(obj_struct, 'histout')
    obj.histout = obj_struct.histout;
  end
  
end
