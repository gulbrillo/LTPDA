% STRING writes a command string that can be used to recreate the input window object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input window object.
%
% CALL:        cmd = string(sw)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

  % Get specwin objects
  sw = [varargin{:}];

  if length(sw) > 1
    cmd = '[';
  else
    cmd = '';
  end

  for jj = 1:length(sw)
    switch lower(sw(jj).type)
      case 'kaiser'
        cmd = [cmd ' specwin(''' sw(jj).type ''', ' num2str(sw(jj).len) ', ' num2str(sw(jj).psll) ')'];
      case 'levelledhanning'
        cmd = [cmd ' specwin(''' sw(jj).type ''', ' num2str(sw(jj).len) ', ' num2str(sw(jj).level) ')'];
      otherwise
        cmd = [cmd ' specwin(''' sw(jj).type ''', ' num2str(sw(jj).len) ')'];
    end
  end

  if length(sw) > 1
    cmd = [cmd ']'];
  end

  % Set output
  varargout{1} = cmd;

end

