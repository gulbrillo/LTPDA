% FROMVALUES construct a pest object from different values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromValues
%
% DESCRIPTION: Construct a pest object from different values.
%
% CALL:        pe = fromValues(pe, pli)
%
% PARAMETER:   pe  - empty pest object
%              pli - input plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromValues(obj, pli)
  
  % get pzmodel info
  ii = pest.getInfo('pest', 'From Values');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % set values
  obj.y = pl.find('y');
  
  % set names
  obj.names  = pl.mfind('paramNames', 'names', 'params');
  
  if isempty(obj.names)
    names = {};
    for kk=1:numel(obj.y)
      names = [names {sprintf('P%d', kk)}];
    end
    obj.names = names;
  end
  
  % Add history
  obj.addHistory(ii, pl, [], []);
  
  % Set object properties
  obj.setObjectProperties(pl);
  
end
