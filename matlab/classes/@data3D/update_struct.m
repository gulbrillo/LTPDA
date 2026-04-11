% UPDATE_STRUCT update the input structure to the current ltpda version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    update_struct
%
% DESCRIPTION: UPDATE_STRUCT update the input structure to the current
%              ltpda version
%
% CALL:        [obj_struct, obj_class] = update_struct(obj_struct, version_str);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = update_struct(varargin)
  
  obj_struct = varargin{1};
  struct_ver = varargin{2};
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update to new ltpda_vector format  %%%%%%%%%%%%%%%%%%%%%%%
  
  % call superclass to update y axis
  obj_struct = ltpda_data.update_struct(obj_struct, struct_ver);
  
  % Check which data version we have
  if isfield(obj_struct, 'zaxis') && isstruct(obj_struct.zaxis)
    obj_struct.zaxis = utils.helper.getObjectFromStruct(obj_struct.zaxis);
  else
    
    % now handle z axis
    z      = [];
    dz     = [];
    zunits = [];
    
    if isfield(obj_struct, 'z')
      z = obj_struct.z;
      obj_struct = rmfield(obj_struct, 'z');
    end
    if isfield(obj_struct, 'dz')
      dz = obj_struct.dz;
      obj_struct = rmfield(obj_struct, 'dz');
    end
    if isfield(obj_struct, 'zunits')
      zunits = unit(obj_struct.zunits);
      obj_struct = rmfield(obj_struct, 'zunits');
    end
    obj_struct.zaxis = ltpda_vector(z, dz, zunits);
  end
  
  varargout{1} = obj_struct;
end

