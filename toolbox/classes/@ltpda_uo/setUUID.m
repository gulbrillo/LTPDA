% SETUUID Set the property 'UUID'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETUUID Set the property 'UUID'
%
% CALL:        objs.setUUID('new UUID');
%              objs = setUUID(objs, 'new UUID');
%
% INPUTS:      objs - is a general object
%
% REMARK:      This method doesn't add history because it is only for
%              internal usage. e.g. in addHistoryStep.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = setUUID(objs, val)
  
  if nargin<2
    val = {char(java.util.UUID.randomUUID)};
  else
    val = cellstr(val);
  end
  
  % Replicate the values in 'val' to the number of AOs
  if numel(val) <= 1 && numel(objs) ~= 1
    val = cell(size(objs));
    val = cellfun(@(x) char(java.util.UUID.randomUUID), val, 'UniformOutput', false);
  end
  
  %%% decide whether we modify the ltpda_uo-object, or create a new one.
  objs = copy(objs, nargout);
  
  %%% set 'UUID'
  for ii=1:numel(objs)
    objs(ii).UUID = val{ii};
  end
end
