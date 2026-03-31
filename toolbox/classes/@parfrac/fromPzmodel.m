%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPzmodel
%
% DESCRIPTION: Construct a parfrac from a pzmodel
%
% CALL:        r = fromPzmodel(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = fromPzmodel(r, pli)
  
  % get pzmodel info
  ii = parfrac.getInfo('parfrac', 'From Pzmodel');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  pzm = find_core(pl, 'pzmodel');
  
  %--- Convert to parfrac
  
  ps = [];
  zs = [];
  if ~isempty(pzm.poles(:))
    ps = vertcat(pzm.poles(:).ri);
  end
  if ~isempty(pzm.zeros(:))
    zs = vertcat(pzm.zeros(:).ri);
  end
  
  % get math gain out of the pzmodel
  gs = utils.math.getk(zs,ps,pzm.gain);
  [res, poles, dterms, pmul] = utils.math.cpf('INOPT', 'PZ', ...
    'POLES', ps, ...
    'ZEROS', zs, ...
    'GAIN', gs, ...
    'MODE', 'SYM');
  
  r.res = res;
  r.poles = poles;
  r.pmul = pmul;
  r.dir = dterms;
  
  % Set other properties
  if isempty(pl.find_core('ounits'))
    pl.pset('ounits', pzm.ounits);
  end
  
  if isempty(pl.find_core('iunits'))
    pl.pset('iunits', pzm.iunits);
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('parfrac(%s)', pzm.name));
  end
  
  if isempty(pl.find_core('description'))
    pl.pset('description', pzm.description);
  end
  
  % Add history
  r.addHistory(ii, pl, [], pzm.hist);
  
  % Set object properties
  r.setObjectProperties(pl);
  
end
