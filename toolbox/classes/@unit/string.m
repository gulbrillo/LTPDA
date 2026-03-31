% STRING converts a unit object to a command string which will recreate the unit object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING converts a unit object to a command string which will
%              recreate the unit object.
%
% CALL:        cmd = string(u)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

  objs = [varargin{:}];

  pstr = '[ ';

  for ii = 1:numel(objs)
    pstr = [pstr 'unit('''];
    pstr = [pstr strrep(strrep(char(objs(ii)), '[', ' '), ']', ' ')];
    pstr = [pstr ''') '];
    
  end

  pstr = [pstr ']'];
  
  varargout{1} = pstr;
end

