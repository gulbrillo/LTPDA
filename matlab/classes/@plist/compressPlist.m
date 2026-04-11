function pl = compressPlist(pl)
  
  DID_COPY = false;
  for kk=1:length(pl.params)
    
    val = pl.params(kk).getVal();
    newval = {};
    if isa(val, 'history')
      
      newval = {val.UUID};
      
    elseif iscell(val)
      
      for ll=1:numel(val)
        v = val{ll};
        if isa(v, 'history')
          newval{ll} = {v.UUID};
        elseif isa(v, 'ltpda_uoh')
          newval{ll} = {v.hist.UUID};
        else
          newval{ll} = v;
        end        
      end
    end
    
    if ~isempty(newval)
      if ~DID_COPY
        pl = copy(pl,1);
      end
      DID_COPY = true;
      pl.params(kk).setVal(newval);
    end
  end  
  
end