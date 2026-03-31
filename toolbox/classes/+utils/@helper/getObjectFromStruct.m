

function obj = getObjectFromStruct(obj_struct)
  
  if isa(obj_struct, 'ltpda_obj')
    obj = obj_struct;
  else
    objCl = utils.helper.getClassFromStruct(obj_struct);
    if ~isempty(objCl)
      % Call constructor of the data class
      obj = feval(objCl, obj_struct);
    else
      obj = obj_struct;
    end
  end
  
end
