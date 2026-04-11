%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPzmodel
%
% DESCRIPTION: Construct a rational from a pzmodel
%
% CALL:        r = fromPzmodel(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = fromPzmodel(r, pli)
  
  % get pzmodel info
  ii = rational.getInfo('rational', 'From Pzmodel');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  pzm = find_core(pl, 'pzmodel');
  
  %--- Convert to rational
  
  % get normalising gains
  pg = 1;
  for jj=1:numel(pzm.poles)
    if pzm.poles(jj).q > 0.5
      pg = pg .* 4*pi*pi*pzm.poles(jj).f*pzm.poles(jj).f;
    else
      pg = pg .* 2*pi*pzm.poles(jj).f;
    end
  end
  zg = 1;
  for jj=1:numel(pzm.zeros)
    if pzm.zeros(jj).q > 0.5
      zg = zg .* 4*pi*pi*pzm.zeros(jj).f*pzm.zeros(jj).f;
    else
      zg = zg .* 2*pi*pzm.zeros(jj).f;
    end
  end
  % construct rational terms
  if isempty(pzm.poles) % in case on no poles
    den = 1;
  else
    den = poly(vertcat(pzm.poles(:).ri))./pg;
  end
  if isempty(pzm.zeros) % in case on no zeros
    num = pzm.gain;
  else
    num = pzm.gain.*poly(vertcat(pzm.zeros(:).ri))./zg;
  end
  
  r.num = num;
  r.den = den;
  
  % Override some properties from the input pzmodel
  if isempty(pl.find('ounits'))
    pl.pset('ounits', pzm.ounits);
  end
  
  if isempty(pl.find('iunits'))
    pl.pset('iunits', pzm.iunits);
  end
  
  if isempty(pl.find('name'))
    pl.pset('name', sprintf('rational(%s)', pzm.name));
  end
  
  if isempty(pl.find('description'))
    pl.pset('description', pzm.description);
  end
  
  % Add history
  r.addHistory(ii, pl, [], pzm.hist);
  
  % Set object properties
  r.setObjectProperties(pl);
  
end
