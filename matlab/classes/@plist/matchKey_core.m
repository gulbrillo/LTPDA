function matches = matchKey_core(pl, key)

  if isempty(pl.keys)
    dkeys = pl.getAllKeys();
  else
    dkeys = pl.keys;
  end
  
  if isempty(dkeys)
    dkeys = {''};
  end
  
  res = cellfun('isclass', dkeys, 'char'); 
  
  % Get value we want
  if all(res(:))
    % 'old' case without alternatives
    matches = strcmpi(key, dkeys);
  else
    % 'new' case with alternatives
    fcn = @(x) strcmpi(x, key);
    res = cellfun(fcn, dkeys, 'UniformOutput', false);
    matches = cellfun(@any, res);
  end
  
end