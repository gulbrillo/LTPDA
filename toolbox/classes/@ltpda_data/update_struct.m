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
  
  % Check which data version we have
  if isfield(obj_struct, 'yaxis') && isstruct(obj_struct.yaxis)
    obj_struct.yaxis = utils.helper.getObjectFromStruct(obj_struct.yaxis);
  else
    
    % now handle y axis
    y      = [];
    dy     = [];
    yunits = [];
    
    if isfield(obj_struct, 'y')
      y = obj_struct.y;
      obj_struct = rmfield(obj_struct, 'y');
    end
    if isfield(obj_struct, 'dy')
      dy = obj_struct.dy;
      obj_struct = rmfield(obj_struct, 'dy');
    end
    if isfield(obj_struct, 'yunits')
      yunits = unit(obj_struct.yunits);
      obj_struct = rmfield(obj_struct, 'yunits');
    end
    
    obj_struct.yaxis = ltpda_vector(y, dy, yunits);
  end
  
  varargout{1} = obj_struct;
end

