function matches = matchKeys_core(pl, keys)
  
  % The command cellstr doesn't work here because it is possible that the
  % second input is a cell-string with alternatives (some values inside the
  % cell are cells). This is only necessary for internal usage.
  if ischar(keys)
    keys = {keys};
  end
  
  matches = zeros(size(pl.params));
  for ii = 1:numel(keys)
    if ischar(keys{ii})
      matches = matches | matchKey_core(pl, keys{ii});
    else
      % For the case that the keys have alternative key names
      matches = matches | matchKeys_core(pl, keys{ii});
    end
  end
  
end