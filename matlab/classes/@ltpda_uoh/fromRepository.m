% Retrieve a ltpda_uo from a repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromRepository
%
% DESCRIPTION: Retrieve a ltpda_uo from a repository
%
% CALL:        obj = fromRepository(pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objs = fromRepository(obj, pli)
  
  % Call super class
  [objs, plh, ii] = fromRepository@ltpda_uo(obj, pli);

  for ll = 1:numel(objs)
    %---- Add history
    objs(ll).addHistoryWoChangingUUID(ii, plh(ll), [], objs(ll).hist);
    
    % Set properties from the plist
    objs.setObjectProperties(pli);
  end
  
  
end

