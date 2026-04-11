% FROMFILTERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromFilters
%
% DESCRIPTION: Construct an filterbank from a set of filters
%
% CALL:        fb = fromFilters(fb, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromFilters(obj, pli)
  
  % get filterbank info
  ii = filterbank.getInfo('filterbank', 'From Filters');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  filters  = pl.find_core('filters');
  type     = pl.find_core('type');
  
  obj.filters = copy(filters,1);
  obj.type    = type;
  
  % Add history
  obj.addHistory(ii, pl, [], []);
  
  % Set object properties
  obj.setObjectProperties(pl);
  
end
