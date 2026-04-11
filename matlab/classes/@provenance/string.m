% STRING writes a command string that can be used to recreate the input provenance object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input provenance object.
%
% CALL:        cmd = string(obj)
%
% INPUT:       obj - provenance object
%
% OUTPUT:      cmd - command string to create the input object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmd = string(varargin)

  objs = [varargin{:}];

  %%% Wrap the command only in bracket if the there are more than one object
  if length(objs) > 1
    cmd = '[';
  else
    cmd = '';
  end

  for j=1:length(objs)
    creator = objs(j).creator;
    cmd = [cmd 'provenance(''' creator ''') '];
  end

  if length(objs) > 1
    cmd = [cmd ']'];
  end
end

