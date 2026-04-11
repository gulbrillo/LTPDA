% FROMSTRUCT creates from a structure an SSM object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure an SSM object.
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
    
    % Set 'amats'
    if isfield(up_struct, 'amats')
      objs(kk).amats = up_struct.amats;
    end
    
    % Set 'bmats'
    if isfield(up_struct, 'bmats')
      objs(kk).bmats = up_struct.bmats;
    end
    
    % Set 'cmats'
    if isfield(up_struct, 'cmats')
      objs(kk).cmats = up_struct.cmats;
    end
    
    % Set 'dmats'
    if isfield(up_struct, 'dmats')
      objs(kk).dmats = up_struct.dmats;
    end
    
    % Set 'timestep'
    if isfield(up_struct, 'timestep')
      objs(kk).timestep = up_struct.timestep;
    end
    
    % Set 'inputs' object
    if isfield(up_struct, 'inputs')
      objs(kk).inputs = utils.helper.getObjectFromStruct(up_struct.inputs);
    end
    
    % Set 'states' object
    if isfield(up_struct, 'states')
      objs(kk).states = utils.helper.getObjectFromStruct(up_struct.states);
    end
    
    % Set 'outputs' object
    if isfield(up_struct, 'outputs')
      objs(kk).outputs = utils.helper.getObjectFromStruct(up_struct.outputs);
    end
    
    % Set 'numparams' object
    if isfield(up_struct, 'numparams')
      objs(kk).numparams = utils.helper.getObjectFromStruct(up_struct.numparams);
    end
    
    % Set 'params' object
    if isfield(up_struct, 'params')
      objs(kk).params = utils.helper.getObjectFromStruct(up_struct.params);
    end
    
  end
  
end

