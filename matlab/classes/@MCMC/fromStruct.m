% FROMSTRUCT creates from a structure a TIMESPAN object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a TIMESPAN object.
%
% CALL:        obj = fromStruct(obj, struct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = fromStruct(objs, obj_struct)
  
  % Get the class name of the object.
  cn = class(objs);
  
  % Define function name for updating the structure
  % fcnName = ([cn '.update_struct']);
  
  % Initialize output objects
  objs = feval([cn '.initObjectWithSize'], size(obj_struct, 1), size(obj_struct, 2));
  
  % Update structure (if necessary)
  for kk = 1:numel(obj_struct)
    
    % Get structure version
    % if isfield(obj_struct, 'tbxver')
    %   tbxVer = obj_struct(kk).tbxver;
    % else
    %   tbxVer = '1.0';
    % end
    % Update structure
    % obj_struct = feval(fcnName, obj_struct(kk), tbxVer);
    
    % Call super-class
    objs(kk) = fromStruct@ltpda_uoh(objs(kk), obj_struct);
    
    % Set 'params' object
    if isfield(obj_struct, 'params')
      objs(kk).params = utils.helper.getObjectFromStruct(obj_struct.params);
    end
    
    % Set 'package' object
    if isfield(obj_struct, 'package')
      objs(kk).package = utils.helper.getObjectFromStruct(obj_struct.package);
    end
    
    % Set 'category' object
    if isfield(obj_struct, 'category')
      objs(kk).category = utils.helper.getObjectFromStruct(obj_struct.category);
    end
    
    % Set 'model' object
    if isfield(obj_struct, 'model')
      objs(kk).model = utils.helper.getObjectFromStruct(obj_struct.model);
    end
    
    % Set 'inputs' object
    if isfield(obj_struct, 'inputs')
      objs(kk).inputs = utils.helper.getObjectFromStruct(obj_struct.inputs);
    end
    
    % Set 'noise' object
    if isfield(obj_struct, 'noise')
      objs(kk).noise = utils.helper.getObjectFromStruct(obj_struct.noise);
    end
    
    % Set 'diffStep' object
    if isfield(obj_struct, 'diffStep')
      if isnumeric(obj_struct) 
        objs(kk).diffStep = utils.helper.getObjectFromStruct(obj_struct.diffStep);
      else
        objs(kk).diffStep = obj_struct.diffStep;
      end
    end
    
    % Set 'logParams' object
    if isfield(obj_struct, 'logParams')
      objs(kk).logParams = obj_struct.logParams;
    end
    
    % Set 'processedModel' object
    if isfield(obj_struct, 'processedModel')
      objs(kk).processedModel = utils.helper.getObjectFromStruct(obj_struct.processedModel);
    end
    
    % Set 'freqs' object
    if isfield(obj_struct, 'freqs')
      objs(kk).freqs = obj_struct.freqs;
    end
    
    % Set 'outputs' object
    if isfield(obj_struct, 'outputs')
      objs(kk).outputs = utils.helper.getObjectFromStruct(obj_struct.outputs);
    end
    
    % Set 'pest' object
    if isfield(obj_struct, 'pest')
      objs(kk).pest = utils.helper.getObjectFromStruct(obj_struct.pest);
    end
    
    % Set 'loglikelihood' object
    if isfield(obj_struct, 'loglikelihood')
      objs(kk).loglikelihood = utils.helper.getObjectFromStruct(obj_struct.loglikelihood);
    end
    
    % Set 'covariance' object
    if isfield(obj_struct, 'covariance')
      if isnumeric(obj_struct.covariance)
        objs(kk).covariance = obj_struct.covariance;
      else
        objs(kk).covariance = utils.helper.getObjectFromStruct(obj_struct.covariance);
      end
    end
  end
  
end

% END