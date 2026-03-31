% STRING writes a command string that can be used to recreate the input pz object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate
%              the input pz object.
%
% CALL:        cmd = string(pz)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)
  
  p = utils.helper.collect_objects(varargin(:), 'pz');
  
  cmd = '';
  for j=1:numel(p)
    
    fstr = num2str(p(j).f, 20);
    qstr = num2str(p(j).q, 20);
    
    % Create from 'f' and 'q'
    pzstr = ['pz(' fstr ',' qstr ') '];
    
    test = eval(pzstr);
    
    % Check if the precision of 'f' and 'q' are high enough
    if ~isequal(test, p(j))
      % Create from ri
      pzstr = ['pz(plist(''ri'', ' mat2str(p(j).ri, 20) ')) '];
    end
    
    cmd = [cmd pzstr];
    
  end
  
  %%% Wrap the command only with brackets if the there are more than one object
  if numel(p) > 1
    cmd = ['[' cmd(1:end-1) ']'];
  end
  
  % set output
  varargout{1} = cmd;
end

