% FROMSTRUCT creates from a structure a HISTORY object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a HISTORY object.
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
    
    % Set 'methodInfo' object
    if isfield(up_struct, 'methodInfo')
      objs(kk).methodInfo = utils.helper.getObjectFromStruct(up_struct.methodInfo);
    end
    
    % Set 'plistUsed' object
    if isfield(up_struct, 'plistUsed')
      objs(kk).plistUsed = utils.helper.getObjectFromStruct(up_struct.plistUsed);
    end
    
    % Set 'methodInvars' object
    if isfield(up_struct, 'methodInvars')
      objs(kk).methodInvars = up_struct.methodInvars;
    end
    
    % Set 'inhists' object
    if isfield(up_struct, 'inhists')
      objs(kk).inhists = utils.helper.getObjectFromStruct(up_struct.inhists);
    end
    
    % Set 'proctime' object
    if isfield(up_struct, 'proctime')
      objs(kk).proctime = up_struct.proctime;
    end
    
    % Set 'UUID' object
    if isfield(up_struct, 'UUID')
      objs(kk).UUID = up_struct.UUID;
    end
    
    % Set 'objectClass' object
    if isfield(up_struct, 'objectClass')
      objs(kk).objectClass = up_struct.objectClass;
    end
    
  end
  
end

