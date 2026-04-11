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
  if isfield(obj_struct, 'xaxis') && isstruct(obj_struct.xaxis)
    obj_struct.xaxis = utils.helper.getObjectFromStruct(obj_struct.xaxis);
  else
    
    % now handle x axis
    x      = [];
    dx     = [];
    xunits = [];
    
    if isfield(obj_struct, 'x')
      x = obj_struct.x;
      obj_struct = rmfield(obj_struct, 'x');
    end
    if isfield(obj_struct, 'dx')
      dx = obj_struct.dx;
      obj_struct = rmfield(obj_struct, 'dx');
    end
    if isfield(obj_struct, 'xunits')
      xunits = unit(obj_struct.xunits);
      obj_struct = rmfield(obj_struct, 'xunits');
    end
    obj_struct.xaxis = ltpda_vector(x, dx, xunits);
  end
  
  varargout{1} = obj_struct;
end

