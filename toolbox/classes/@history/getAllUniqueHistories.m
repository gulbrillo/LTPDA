function [collHists, collUUIDs] = getAllUniqueHistories(inHists)

  [collHists, collUUIDs] = internal_getAllUniqueHistories(inHists, {}, []);
  
end

function [collHists, collUUIDs] = internal_getAllUniqueHistories(inHists, collUUIDs, collHists)
  
  for hh = 1:numel(inHists)
    
    inHist = inHists(hh);
    
    if ~any(strcmp(inHist.UUID, collUUIDs))
      
      pl = inHist.plistUsed;
      
      collUUIDs = [collUUIDs {inHist.UUID}];
      collHists = [collHists copyHistory(inHist)];
      
      % Collect the histories from the inhists
      if ~isempty(inHist.inhists)
        [collHists, collUUIDs] = internal_getAllUniqueHistories(inHist.inhists, collUUIDs, collHists);
      end
      
      % Collect the histories from the plistUsed
      for kk=1:length(pl.params)
        
        val = pl.params(kk).getVal();
        
        if ~isempty(val)
          
          if isa(val, 'history')
            [collHists, collUUIDs] = internal_getAllUniqueHistories(val, collUUIDs, collHists);
            
          elseif iscell(val)
            
            idx = cellfun(@(x) isa(x, 'history'), val);
            tmp = [val{idx}];
            [collHists, collUUIDs] = internal_getAllUniqueHistories(tmp, collUUIDs, collHists);
            
          end
        end
        
      end % Loop plistUsed parameters
      
    end % Loop inHists
    
  end
  
end

% Simple copy just to populate the new container. No need to copy inner
% objects. The plist will be copied only in the case it's modified (in
% compressPlist) and the inhists will anyway be emptied later on when the
% list is fully compiled.
function new = copyHistory(old)
  
  new = history.newarray(size(old));
  
  for kk=1:numel(old)
    new(kk).plistUsed    = old(kk).plistUsed;
    new(kk).methodInfo   = old(kk).methodInfo;
    new(kk).methodInvars = old(kk).methodInvars;
    new(kk).inhists      = old(kk).inhists;
    new(kk).proctime     = old(kk).proctime;
    new(kk).UUID         = old(kk).UUID;
    new(kk).objectClass  = old(kk).objectClass;
    new(kk).context      = old(kk).context;
    new(kk).creator      = old(kk).creator;
  end

end
