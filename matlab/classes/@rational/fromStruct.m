% FROMSTRUCT creates from a structure a RATIONAL object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a RATIONAL object.
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
    objs(kk) = fromStruct@ltpda_tf(objs(kk), up_struct);
    
    % Set 'num'
    if isfield(up_struct, 'num')
      objs(kk).num = up_struct.num;
    end
    
    % Set 'den'
    if isfield(up_struct, 'den')
      objs(kk).den = up_struct.den;
    end
    
  end
  
end

