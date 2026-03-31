%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromCoefficients
%
% DESCRIPTION: Construct a rational from num and den coefficients
%
% CALL:        r = fromCoefficients(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = fromCoefficients(r, pli)
  
  % get pzmodel info
  ii = rational.getInfo('rational', 'From Coefficients');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  r.num = find_core(pl, 'num');
  r.den = find_core(pl, 'den');
  
  % Add history
  r.addHistory(ii, pl, [], []);
  
  % Set object properties
  r.setObjectProperties(pl);
  
end
