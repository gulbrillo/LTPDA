% CHECKFILTEROPTIONS checks the options to the different filter
% constructors are correct.
function checkFilterOptions(pl)
  g      = find(pl, 'gain');
  fc     = find(pl, 'fc');
  fs     = find(pl, 'fs');
  order  = find(pl, 'order');
  win    = find(pl, 'Win');
  
  if numel(fc) == 1
    
    if(fc(1) >= fs/2)
      error('fc [%g] must be < fs/2 [%g]', fc(1), fs/2);
    end

  elseif numel(fc) == 2
    
    if any(fc >= fs/2)
      error('### fc must be < fs/2');
    end
    if any(fc == 0)
      error('### fc must be > 0');
    end
    if(fc(1) > fc(2))
      error('### fc(1) must be < fc(2)');
    end
    
  else
    error('The frequency cut-offs [fc] should be two elements only');
  end
  
end