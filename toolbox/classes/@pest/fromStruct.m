% FROMSTRUCT creates from a structure a PEST object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a PEST object.
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
    
    % Set 'dy'
    if isfield(up_struct, 'dy')
      objs(kk).dy = up_struct.dy;
    end
    
    % Set 'y'
    if isfield(up_struct, 'y')
      objs(kk).y = up_struct.y;
    end
    
    % Set 'names'
    if isfield(up_struct, 'names')
      objs(kk).names = up_struct.names;
    end
    
    % Set 'yunits'
    if isfield(up_struct, 'yunits')
      objs(kk).yunits = utils.helper.getObjectFromStruct(up_struct.yunits);
    end
    
    % Set 'pdf'
    if isfield(up_struct, 'pdf')
      objs(kk).pdf = up_struct.pdf;
    end
    
    % Set 'cov'
    if isfield(up_struct, 'cov')
      objs(kk).cov = up_struct.cov;
    end
    
    % Set 'corr'
    if isfield(up_struct, 'corr')
      objs(kk).corr = up_struct.corr;
    end
    
    % Set 'chi2'
    if isfield(up_struct, 'chi2')
      objs(kk).chi2 = up_struct.chi2;
    end
    
    % Set 'dof'
    if isfield(up_struct, 'dof')
      objs(kk).dof = up_struct.dof;
    end
    
    % Set 'chain'
    if isfield(up_struct, 'chain')
      objs(kk).chain = up_struct.chain;
    end
    
    % Set 'models'
    if isfield(up_struct, 'models')
      objs(kk).models = utils.helper.getObjectFromStruct(up_struct.models);
    end
    
  end
  
end

