% FROMSTRUCT creates from a structure a MINFO object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a MINFO object.
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
    
    % Set 'mname' object
    if isfield(up_struct, 'mname')
      objs(kk).mname = up_struct.mname;
    end
    
    % Set 'mclass' object
    if isfield(up_struct, 'mclass')
      objs(kk).mclass = up_struct.mclass;
    end
    
    % Set 'mpackage' object
    if isfield(up_struct, 'mpackage')
      % Workaround: The minfo constructor expects that the property
      %             'mpackage' is filled.
      if ~isempty(up_struct.mpackage)
        objs(kk).mpackage = up_struct.mpackage;
      end
    end
    
    % Set 'mcategory' object
    if isfield(up_struct, 'mcategory')
      objs(kk).mcategory = up_struct.mcategory;
    end
    
    % Set 'mversion' object
    if isfield(up_struct, 'mversion')
      objs(kk).mversion = up_struct.mversion;
    end
    
    % Set 'description' object
    if isfield(up_struct, 'description')
      objs(kk).description = up_struct.description;
    end
    
    % Set 'children' object
    if isfield(up_struct, 'children')
      objs(kk).children = utils.helper.getObjectFromStruct(up_struct.children);
    end
    
    % Set 'sets' object
    if isfield(up_struct, 'sets')
      objs(kk).sets = up_struct.sets;
    end
    
    % Set 'plists' object
    if isfield(up_struct, 'plists')
      objs(kk).plists = utils.helper.getObjectFromStruct(up_struct.plists);
    end
    
    % Set 'argsmin' object
    if isfield(up_struct, 'argsmin')
      objs(kk).argsmin = up_struct.argsmin;
    end
    
    % Set 'argsmax' object
    if isfield(up_struct, 'argsmax')
      objs(kk).argsmax = up_struct.argsmax;
    end
    
    % Set 'outmin' object
    if isfield(up_struct, 'outmin')
      objs(kk).outmin = up_struct.outmin;
    end
    
    % Set 'outmax' object
    if isfield(up_struct, 'outmax')
      objs(kk).outmax = up_struct.outmax;
    end
    
    % Set 'modifier' object
    if isfield(up_struct, 'modifier')
      objs(kk).modifier = up_struct.modifier;
    end
    
  end
  
end

