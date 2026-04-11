% STRING converts a ssmblock object to a command string which will recreate the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING converts a ssmblock object to a command string which will
%              recreate the ssmblock object.
%
% CALL:        cmd = string(u)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)
  
  objs = [varargin{:}];
  
  pstr = '[ ';
  
  for ii = 1:numel(objs)
    pstr = [pstr 'ssmblock('];
    pstr = [pstr '''' objs(ii).name '''' ',' string(objs(ii).ports) ',' '''' objs(ii).description ''''];
    pstr = [pstr ''') '];
    
  end
  
  pstr = [pstr ']'];
  
  varargout{1} = pstr;
end

