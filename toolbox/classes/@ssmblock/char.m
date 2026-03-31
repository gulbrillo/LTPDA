% CHAR convert a ssmblock object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a ssmblock object into a string.
%
% CALL:        string = char(ssmblock)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)
  objs = [varargin{:}];
  
  pstr = '';
  for ii = 1:numel(objs)
    pstr = [objs(ii).name ' | ' char(objs(ii).ports, objs(ii).name) ', '];
  end
  
  % remove last ', '
  if length(pstr)>1
    pstr = pstr(1:end-2);
  end
  
  %%% Prepare output
  varargout{1} = pstr;
end
