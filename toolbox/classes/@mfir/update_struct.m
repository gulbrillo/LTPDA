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
      
      %%%   a
      if isfield(obj_struct, 'gain') && ~isempty(obj_struct.gain) && obj_struct.gain ~= 0
        obj_struct.a = obj_struct.a * obj_struct.gain;
      end
      
      %%%   gd
      if ~isfield(obj_struct, 'gd')
        obj_struct.gd      = 0;
      end
      
      %%%   creator
      if isfield(obj_struct, 'provenance') && ~isfield(obj_struct, 'creator')
        obj_struct.creator = obj_struct.provenance;
      elseif ~isfield(obj_struct, 'creator')
        obj_struct.creator = provenance('Updater 1.0 -> 1.9.1');
      end
      
      %%%%%   hist
      if ~isfield(obj_struct, 'hist')
        if isfield(obj_struct, 'class')
          cn = obj_struct.class;
        else
          cn = 'unknown class. updater';
        end
        ii = minfo('update_struct', cn, 'ltpda', '', '', ...
          {'Default'}, plist(), 0, 0);
        obj_struct.hist = history(time().utc_epoch_milli, ii, obj_struct.plist);
      end
      
    catch ME
      disp(varargin{1});
      throw(addCause(ME, MException('MATLAB:LTPDA','### The struct (mfir) above is not from version 1.0')));
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
    
    %%%   created
    if isfield(obj_struct, 'created')
      obj_struct = rmfield(obj_struct, 'created');
    end
    
    %%%   creator
    if isfield(obj_struct, 'creator')
      obj_struct = rmfield(obj_struct, 'creator');
    end
    
    struct_ver = '1.9.4';
  end
  
  %%%   ntaps
  if isfield(obj_struct, 'ntaps')
    obj_struct = rmfield(obj_struct, 'ntaps');
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

