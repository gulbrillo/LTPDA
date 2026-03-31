%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromParfrac
%
% DESCRIPTION: Construct a rational from parfrac model
%
% CALL:        r = Parfrac(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = fromParfrac(r, pli)
  
  % get pzmodel info
  ii = rational.getInfo('rational', 'From Parfrac');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Extrac model
  
  pf = find_core(pl, 'parfrac');
  [a,b] = residue(pf.res,pf.poles,pf.dir);
  
  % Set fields
  r.num = a;
  r.den = b;
  
  % Override model properties from the parfrac object
  
  if isempty(pl.find('ounits'))
    pl.pset('ounits', pf.ounits);
  end
  
  if isempty(pl.find('iunits'))
    pl.pset('iunits', pf.iunits);
  end
  
  if isempty(pl.find('name'))
    pl.pset('name', sprintf('rational(%s)', pf.name));
  end
  
  if isempty(pl.find('description'))
    pl.pset('description', pf.description);
  end
  
  % Add history
  r.addHistory(ii, pl, [], pf.hist);
  
  % Set object properties
  r.setObjectProperties(pl);
  
end
