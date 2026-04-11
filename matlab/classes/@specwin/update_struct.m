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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = update_struct(varargin)
  
  obj_struct = varargin{1};
  struct_ver = varargin{2};
  
  % get the version of the current toolbox
  tbx_ver = strtok(getappdata(0, 'ltpda_version'));
  
  % get only the version string without the MATLAB version
  struct_ver = strtok(struct_ver);
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.0 -> 1.9.1'   %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.0')
    
    try
      if isfield(obj_struct, 'name')
        obj_struct.type = obj_struct.name;
      end
    catch ME
      disp(varargin{1});
      throw(addCause(ME, MException('MATLAB:LTPDA','### The struct (specwin) above is not from version 1.0')));
    end
    
    struct_ver = '1.9.1';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.9.1' ->'1.9.2'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.9.1')
    
    struct_ver = '1.9.2';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.9.2' ->'1.9.3'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.9.2')
    
    struct_ver = '1.9.3';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.9.3' ->'1.9.4'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.9.3')
    
    struct_ver = '1.9.4';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.9.4' ->'2.0'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.9.4')
    
    struct_ver = '2.0';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '2.0' ->'2.0.1'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '2.0')
    
    struct_ver = '2.0.1';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '2.0.1' ->'2.1'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '2.0.1')
    
    struct_ver = '2.1';
  end
  
  varargout{1} = obj_struct;
end

