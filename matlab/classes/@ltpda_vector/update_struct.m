% UPDATE_STRUCT update the input structure to the current ltpda version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    update_struct
%
% DESCRIPTION: UPDATE_STRUCT update the input structure to the current
%              ltpda version
%
% CALL:        obj_struct = update_struct(obj_struct, version_str);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = update_struct(varargin)
  
  obj_struct = varargin{1};
  struct_ver = varargin{2};
  
  % get the version of the current toolbox
  tbx_ver = strtok(getappdata(0, 'ltpda_version'));
  
  % get only the version string without the MATLAB version
  struct_ver = strtok(struct_ver);
  
  
  varargout{1} = obj_struct;
end

