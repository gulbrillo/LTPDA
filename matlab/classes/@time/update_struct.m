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

function obj_struct = update_struct(obj_struct, version_str)

  % get only the version string without the MATLAB version and convert to double
  ver = utils.helper.ver2num(strtok(version_str));

  % update from version 1.0
  if ver <= utils.helper.ver2num('1.0')
    if isfield(obj_struct, 'timeformat')
      if isstruct(obj_struct.timeformat)
        obj_struct.timeformat = obj_struct.timeformat.format_str;
      end
    end
  end

  % update from version 2.3
  if ver <= utils.helper.ver2num('2.3')
    if isfield(obj_struct, 'time_str')
      obj_struct = rmfield(obj_struct, 'time_str');
    end
  end

  % update from version 2.4
  if ver <= utils.helper.ver2num('2.4')
    if isfield(obj_struct, 'timeformat')
      obj_struct = rmfield(obj_struct, 'timeformat');
    end
    if isfield(obj_struct, 'timezone')
      obj_struct = rmfield(obj_struct, 'timezone');
    end
  end

end

