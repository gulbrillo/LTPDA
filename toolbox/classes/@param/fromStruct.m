% FROMSTRUCT creates from a structure a PARAM object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a PARAM object.
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
    
    % Set 'key' object
    if isfield(up_struct, 'key')
      objs(kk).key = up_struct.key;
    end
    
    % Set 'val' object
    if isfield(up_struct, 'val')
      val = utils.helper.getObjectFromStruct(up_struct.val);
      
      % Check if 'val' is a cell-array and we have converted every object
      % inside the cell-array.
      if iscell(val)
        for cc = 1:numel(val)
          if isstruct(val{cc})
            val{cc} = utils.helper.getObjectFromStruct(val{cc});
          end
        end
      end
      objs(kk).val = val;
    end
    
    % Set 'desc' object
    if isfield(up_struct, 'desc')
      objs(kk).desc = up_struct.desc;
    end
    
  end
  
end

