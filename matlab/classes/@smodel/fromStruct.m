% FROMSTRUCT creates from a structure a SMODEL object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a SMODEL object.
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

    % Set 'expr' object
    if isfield(up_struct, 'expr')
      objs(kk).expr = utils.helper.getObjectFromStruct(up_struct.expr);
    end
    
    % Set 'params' object
    if isfield(up_struct, 'params')
      objs(kk).params = up_struct.params;
    end
    
    % Set 'values' object
    if isfield(up_struct, 'values')
      objs(kk).values = up_struct.values;
    end
    
    % Set 'trans' object
    if isfield(up_struct, 'trans')
      objs(kk).trans = up_struct.trans;
    end
    
    % Set 'xvar' object
    if isfield(up_struct, 'xvar')
      objs(kk).xvar = up_struct.xvar;
    end
    
    % Set 'xvals' object
    if isfield(up_struct, 'xvals')
      objs(kk).xvals = up_struct.xvals;
    end
    
    % Set 'xunits' object
    if isfield(up_struct, 'xunits')
      objs(kk).xunits = utils.helper.getObjectFromStruct(up_struct.xunits);
    end
    
    % Set 'yunits' object
    if isfield(up_struct, 'yunits')
      objs(kk).yunits = utils.helper.getObjectFromStruct(up_struct.yunits);
    end
    
  end
  
end

