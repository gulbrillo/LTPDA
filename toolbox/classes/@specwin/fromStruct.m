% FROMSTRUCT creates from a structure a SPECWIN object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Creates from a structure a SPECWIN object.
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
    
    % Set 'type' object
    if isfield(up_struct, 'type')
      objs(kk).type = up_struct.type;
    end
    
    % Set 'alpha' object
    if isfield(up_struct, 'alpha')
      objs(kk).alpha = up_struct.alpha;
    end
    
    % Set 'psll' object
    if isfield(up_struct, 'psll')
      objs(kk).psll = up_struct.psll;
    end
    
    % Set 'rov' object
    if isfield(up_struct, 'rov')
      objs(kk).rov = up_struct.rov;
    end
    
    % Set 'nenbw' object
    if isfield(up_struct, 'nenbw')
      objs(kk).nenbw = up_struct.nenbw;
    end
    
    % Set 'w3db' object
    if isfield(up_struct, 'w3db')
      objs(kk).w3db = up_struct.w3db;
    end
    
    % Set 'flatness' object
    if isfield(up_struct, 'flatness')
      objs(kk).flatness = up_struct.flatness;
    end
    
    % Set 'levelorder' object
    if isfield(up_struct, 'levelorder')
      objs(kk).levelorder = up_struct.levelorder;
    end
    
    % Set 'skip' object
    if isfield(up_struct, 'skip')
      objs(kk).skip = up_struct.skip;
    end
    
    % Set 'len' object
    if isfield(up_struct, 'len')
      objs(kk).len = up_struct.len;
    elseif isfield(up_struct, 'win')
      objs(kk).len = length(up_struct.win);
    end
    
%     % Set 'ws' object
%     if isfield(up_struct, 'ws')
%       objs(kk).ws = up_struct.ws;
%     end
%     
%     % Set 'ws2' object
%     if isfield(up_struct, 'ws2')
%       objs(kk).ws2 = up_struct.ws2;
%     end
%     
%     % Set 'win' object
%     if isfield(up_struct, 'win')
%       objs(kk).win = up_struct.win;
%     end
    
  end
  
end

