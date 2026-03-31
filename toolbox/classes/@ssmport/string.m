% STRING converts a ssmport object to a command string which will recreate the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING converts a ssmport object to a command string which will
%              recreate the ssmport object.
%
% CALL:        cmd = string(u)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)
  
  objs = [varargin{:}];
  
  pstr = '[ ';
  
  for ii = 1:numel(objs)
    pstr = [pstr 'ssmport('];
    pstr = [pstr '''' objs(ii).name '''' ',' '''' objs(ii).description '''' ',' string(objs(ii).units)];
    pstr = [pstr ''') '];
    
  end
  
  pstr = [pstr ']'];
  
  varargout{1} = pstr;
end

