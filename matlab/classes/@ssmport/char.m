% CHAR convert a ssmport object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a ssmport object into a string.
%
% CALL:        string = char(ssmport)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)
  objs = varargin{1};
  
  % see if parent block name is there
  if nargin==2
    parentName=varargin{2};
  else
    parentName = '';
  end
  
  pstr = '';
  for ii = 1:numel(objs)
    [blockName, portName] = ssmblock.splitName(objs(ii).name);
    if strcmpi(parentName, blockName)
      pstr = [pstr portName ' ' char(objs(ii).units) ', '];
    else
      pstr = [pstr objs(ii).name ' ' char(objs(ii).units) ', '];
    end
  end
  
  % remove last ', '
  if length(pstr)>1
    pstr = pstr(1:end-2);
  end
  
  %%% Prepare output
  varargout{1} = pstr;
end
