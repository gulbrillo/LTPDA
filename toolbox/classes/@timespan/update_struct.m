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
    % hist
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
    % startT
    if ~isfield(obj_struct, 'startT') && isfield(obj_struct, 'start')
      obj_struct.startT = obj_struct.start;
    elseif ~isfield(obj_struct, 'startT')
      obj_struct.startT = time(0);
    end
    % endT
    if ~isfield(obj_struct, 'endT') && isfield(obj_struct, 'end')
      obj_struct.endT = obj_struct.end;
    elseif ~isfield(obj_struct, 'endT')
      obj_struct.endT = time(0);
    end
  end

  % update from version 1.9.3
  if ver <= utils.helper.ver2num('1.9.3')
    % created
    if isfield(obj_struct, 'created')
      obj_struct = rmfield(obj_struct, 'created');
    end
    % creator
    if isfield(obj_struct, 'creator')
      obj_struct = rmfield(obj_struct, 'creator');
    end
  end

  % update from version 2.3
  if ver <= utils.helper.ver2num('2.3')
    % interval
    if isfield(obj_struct, 'interval')
      obj_struct = rmfield(obj_struct, 'interval');
    end
  end

  % update from version 2.4
  if ver <= utils.helper.ver2num('2.4')
    % timeformat
    if isfield(obj_struct, 'timeformat')
      obj_struct = rmfield(obj_struct, 'timeformat');
    end
    % timezone
    if isfield(obj_struct, 'timezone')
      obj_struct = rmfield(obj_struct, 'timezone');
    end
  end

end

