% FROMSTRUCT creates from a structure a PARAMVALUE object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a PARAMVALUE object.
%
% CALL:        obj = fromStruct(obj, struct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = fromStruct(objs, obj_struct)
  
  % Get the class name of the object.
  cn = class(objs);
  
  % Define function name for updating the structure
  fcnName = ([cn '.update_struct']);
  
  % Initialize output objects
  objs = feval([cn '.initObjectWithSize'], size(obj_struct, 1), size(obj_struct, 2));
  
  % Update structure (if necessary)
  for kk = 1:numel(obj_struct)
    
    % Get structure version
    if isfield(obj_struct, 'tbxver')
      tbxVer = obj_struct(kk).tbxver;
    else
      tbxVer = '1.0';
    end
    % Update structure
    up_struct = feval(fcnName, obj_struct(kk), tbxVer);
    
    % Call super-class
    objs(kk) = fromStruct@ltpda_nuo(objs(kk), up_struct);
    
    % Set 'valIndex' object
    if isfield(up_struct, 'valIndex')
      objs(kk).valIndex = up_struct.valIndex;
    end
    
    % Set 'options' object
    if isfield(up_struct, 'options')
      objs(kk).options = up_struct.options;
    end
    
    % Set 'selection' object
    if isfield(up_struct, 'selection')
      objs(kk).selection = up_struct.selection;
    end
    
    % Set 'property' object
    if isfield(up_struct, 'property')
      objs(kk).property = up_struct.property;
    end
    
  end
  
end


