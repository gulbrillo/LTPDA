% FROMSTRUCT creates from a structure a PROVENANCE object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a PROVENANCE object.
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
    
    % Set 'creator' object
    if isfield(up_struct, 'creator')
      objs(kk).creator = up_struct.creator;
    end
    
    % Set 'ip' object
    if isfield(up_struct, 'ip')
      objs(kk).ip = up_struct.ip;
    end
    
    % Set 'hostname' object
    if isfield(up_struct, 'hostname')
      objs(kk).hostname = up_struct.hostname;
    end
    
    % Set 'os' object
    if isfield(up_struct, 'os')
      objs(kk).os = up_struct.os;
    end
    
    % Set 'matlab_version' object
    if isfield(up_struct, 'matlab_version')
      objs(kk).matlab_version = up_struct.matlab_version;
    end
    
    % Set 'sigproc_version' object
    if isfield(up_struct, 'sigproc_version')
      objs(kk).sigproc_version = up_struct.sigproc_version;
    end
    
    % Set 'symbolic_math_version' object
    if isfield(up_struct, 'symbolic_math_version')
      objs(kk).symbolic_math_version = up_struct.symbolic_math_version;
    end
    
    % Set 'optimization_version' object
    if isfield(up_struct, 'optimization_version')
      objs(kk).optimization_version = up_struct.optimization_version;
    end
    
    % Set 'database_version' object
    if isfield(up_struct, 'database_version')
      objs(kk).database_version = up_struct.database_version;
    end
    
    % Set 'control_version' object
    if isfield(up_struct, 'control_version')
      objs(kk).control_version = up_struct.control_version;
    end
    
    % Set 'ltpda_version' object
    if isfield(up_struct, 'ltpda_version')
      objs(kk).ltpda_version = up_struct.ltpda_version;
    end
    
  end
  
end

