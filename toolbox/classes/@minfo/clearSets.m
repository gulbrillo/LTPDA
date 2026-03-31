% CLEARSETS Clear the sets and plists of the input minfo objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CLEARSETS Clear the sets and plists of the input minfo
%              objects.
%
% CALL:        objs = clearSets(objs)
%              objs.clearSets()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = clearSets(objs)
  
  % Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  for ii = 1:numel(objs)
    objs(ii).sets = {};
    objs(ii).plists = [];
    
    % Clear the sets and plists of the children
    if ~isempty(objs(ii).children)
      clearSets(objs(ii).children);
    end
    
  end
end
