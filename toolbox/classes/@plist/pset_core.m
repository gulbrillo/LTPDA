function pset_core(pl, key, val)
  
  % does the key exist?
  if isempty(pl.params)
    idx = [];
  else
    idx = find(matchKey_core(pl, key));
  end
  
  if isempty(idx)
    % add a new param
    pl.params = [pl.params param(key,val)];
    pl.cacheKey(key);
    
  else
    % set existing param value
    pl.params(idx).setVal(val);
  end
  
end