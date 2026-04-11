% FROMSTRUCT creates from a structure a FSDATA object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a FSDATA object.
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
    objs(kk) = fromStruct@data2D(objs(kk), up_struct);
    
    % Set 't0' object
    if isfield(up_struct, 't0')
      objs(kk).t0 = utils.helper.getObjectFromStruct(up_struct.t0);
    end
    
    % Set 'navs' object
    if isfield(up_struct, 'navs')
      objs(kk).navs = up_struct.navs;
    end
    
    % Set 'fs' object
    if isfield(up_struct, 'fs')
      objs(kk).fs = up_struct.fs;
    end
    
    % Set 'enbw' object
    if isfield(up_struct, 'enbw')
      objs(kk).enbw = up_struct.enbw;
    end
    
  end
  
end

