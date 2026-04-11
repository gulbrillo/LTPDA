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
      %       obj_struct = rmfield(obj_struct, 'name');
      %       obj_struct = rmfield(obj_struct, 'created');
    catch ME
      disp(varargin{1});
      throw(addCause(ME, MException('MATLAB:LTPDA','### The struct (fsdata) above is not from version 1.0')));
    end
    
    struct_ver = '1.9.1';
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update version '1.9.1' ->'1.9.2'  %%%%%%%%%%%%%%%%%%%%%%%
  
  if utils.helper.ver2num(struct_ver) < utils.helper.ver2num(tbx_ver) && ...
      strcmp(struct_ver, '1.9.1')
    
    %%% update xunits
    if ~isa(obj_struct.xunits, 'unit')
      % Make sure we have strings for the units
      obj_struct.xunits = char(obj_struct.xunits);
      
      % Set default value ('empty') in 1.9.1 to an empty string to avoid warnings.
      if strcmp(obj_struct.xunits, 'empty')
        obj_struct.xunits = '';
      end
      
      % We need to fix any strange old units
      
      %- /\surdHz -> Hz^-0.5
      obj_struct.xunits = strrep(obj_struct.xunits, '/\surdHz', 'Hz^-0.5');
      obj_struct.xunits = strrep(obj_struct.xunits, '/Hz', 'Hz^-1');
      obj_struct.xunits = strrep(obj_struct.xunits, 'N/A', 'arb');
      obj_struct.xunits = strrep(obj_struct.xunits, 'Arb', 'arb');
      obj_struct.xunits = strrep(obj_struct.xunits, 'Hz', ' Hz^-1');
      
      % Check X units
      try
        uo = unit(obj_struct.xunits);
      catch
        warning('!!! This file contains a fsdata object with unsupported x-units [%s]. Setting to empty.', obj_struct.xunits);
        obj_struct.xunits = '';
      end
    end
    
    %%% update yunits
    if ~isa(obj_struct.yunits, 'unit')
      % Make sure we have strings for the units
      obj_struct.yunits = char(obj_struct.yunits);
      
      % Set default value ('empty') in 1.9.1 to an empty string to avoid warnings.
      if strcmp(obj_struct.yunits, 'empty')
        obj_struct.yunits = '';
      end
      
      % We need to fix any strange old units
      
      %- /\surdHz -> Hz^-0.5
      obj_struct.yunits = strrep(obj_struct.yunits, '/\surdHz', 'Hz^-0.5');
      obj_struct.yunits = strrep(obj_struct.yunits, '/Hz', 'Hz^-1');
      obj_struct.yunits = strrep(obj_struct.yunits, 'N/A', 'arb');
      obj_struct.yunits = strrep(obj_struct.yunits, 'Arb', 'arb');
      obj_struct.yunits = strrep(obj_struct.yunits, 'Hz', ' Hz^-1');
      
      % Check Y units
      try
        uo = unit(obj_struct.yunits);
      catch
        warning('!!! This file contains a fsdata object with unsupported y-units [%s]. Setting to empty.', obj_struct.yunits);
        obj_struct.yunits = '';
      end
    end
    
    %%% update zunits
    if ~isa(obj_struct.zunits, 'unit')
      % Make sure we have strings for the units
      obj_struct.zunits = char(obj_struct.zunits);
      
      % Set default value ('empty') in 1.9.1 to an empty string to avoid warnings.
      if strcmp(obj_struct.zunits, 'empty')
        obj_struct.zunits = '';
      end
      
      % We need to fix any strange old units
      
      %- /\surdHz -> Hz^-0.5
      obj_struct.zunits = strrep(obj_struct.zunits, '/\surdHz', 'Hz^-0.5');
      obj_struct.zunits = strrep(obj_struct.zunits, '/Hz', 'Hz^-1');
      obj_struct.zunits = strrep(obj_struct.zunits, 'N/A', 'arb');
      obj_struct.zunits = strrep(obj_struct.zunits, 'Arb', 'arb');
      obj_struct.zunits = strrep(obj_struct.zunits, 'Hz', ' Hz^-1');
      
      % Check Y units
      try
        uo = unit(obj_struct.zunits);
      catch
        warning('!!! This file contains a fsdata object with unsupported y-units [%s]. Setting to empty.', obj_struct.zunits);
        obj_struct.zunits = '';
      end
    end
    
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
  
  %%%%%%%%%%%%%%%%%%%%%%%   Update to new ltpda_vector format  %%%%%%%%%%%%%%%%%%%%%%%
  
  % call superclass to update y axis
  obj_struct = data3D.update_struct(obj_struct, struct_ver);  
  
  varargout{1} = obj_struct;
end

