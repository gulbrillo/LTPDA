% FROMSTRUCT creates from a structure a COLLECTION object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a COLLECTION object.
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
    objs(kk) = fromStruct@ltpda_uoh(objs(kk), up_struct);
    
    % Set 'func'
    if isfield(up_struct, 'func')
      objs(kk).func = up_struct.func;
    end
    
    % Set 'funcDef'
    if isfield(up_struct, 'funcDef')
      objs(kk).funcDef = up_struct.funcDef;
    end
    
    % Set 'subfuncs' object
    if isfield(up_struct, 'subfuncs')
      objs(kk).subfuncs = utils.helper.getObjectFromStruct(up_struct.subfuncs);
    end
    
    % Set 'inputs'
    if isfield(up_struct, 'inputs')
      objs(kk).inputs = up_struct.inputs;
    end
    
    % Set 'inputObjects' object
    if isfield(up_struct, 'inputObjects')
      if iscell(up_struct.inputObjects)
        for cc=1:numel(up_struct.inputObjects)
          up_struct.inputObjects{cc} = utils.helper.getObjectFromStruct(up_struct.inputObjects{cc});
        end
      end
      objs(kk).inputObjects = utils.helper.getObjectFromStruct(up_struct.inputObjects);
    end
    
    % Set 'constants'
    if isfield(up_struct, 'constants')
      % It is possible that the 'constants' are
      % - cell of strings
      % - cell of LTPDANamedItem-structrues
      % - or a mix
      if iscellstr(up_struct.constants)
        objs(kk).constants = up_struct.constants;
      else
        newCell = cell(size(up_struct.constants));
        for cc=1:numel(up_struct.constants)
          newCell{cc} = utils.helper.getObjectFromStruct(up_struct.constants{cc});
        end
        objs(kk).constants = newCell;
      end
    end
    
    % Set 'constObjects' object
    if isfield(up_struct, 'constObjects')
      if iscell(up_struct.constObjects)
        for cc=1:numel(up_struct.constObjects)
          up_struct.constObjects{cc} = utils.helper.getObjectFromStruct(up_struct.constObjects{cc});
        end
      end
      objs(kk).constObjects = utils.helper.getObjectFromStruct(up_struct.constObjects);
    end
    
    % Set 'paramsDef' object
    if isfield(up_struct, 'paramsDef')
      objs(kk).paramsDef = utils.helper.getObjectFromStruct(up_struct.paramsDef);
    end
    
    % Set 'numeric' object
    if isfield(up_struct, 'numeric')
      objs(kk).numeric = up_struct.numeric;
    end
    
  end
  
end


