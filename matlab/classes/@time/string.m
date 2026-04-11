% STRING writes a command string that can be used to recreate the input time object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input time object.
%
% CALL:        cmd = string(time-object);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmd = string(varargin)

  % collect the time-objects
  tt = [varargin{:}];

  cmd = '';
  for jj=1:length(tt)
    pl = plist('milliseconds', tt(jj).utc_epoch_milli);
    cmd = [cmd 'time(' string(pl) ') '];
  end

  % if the there are more than one object wrap the command with brackets 
  if numel(tt) > 1
    cmd = ['[' cmd(1:end-1) ']'];
  end

end

