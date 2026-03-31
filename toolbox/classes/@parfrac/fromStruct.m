% FROMSTRUCT creates from a structure a PARFRAC object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a PARFRAC object.
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
    
    % Set 'res'
    if isfield(up_struct, 'res')
      objs(kk).res = up_struct.res;
    end
    
    % Set 'poles'
    if isfield(up_struct, 'poles')
      objs(kk).poles = up_struct.poles;
    end
    
    % Set 'pmul'
    if isfield(up_struct, 'pmul')
      objs(kk).pmul = up_struct.pmul;
    end
    
    % Set 'dir'
    if isfield(up_struct, 'dir')
      objs(kk).dir = up_struct.dir;
    end
    
  end
  
end

