function uuids = expandHistory(hists)
  
  % fix history tree
  uuids = {hists.UUID};
  
  for kk=1:numel(hists)
    
    h = hists(kk);
    
    inhists = [];
    
    for jj=1:numel(h.inhists)
      uuid = h.inhists{jj};
      idx = strcmp(uuid, uuids);
      inhists = [inhists hists(idx)];
    end
    
    h.inhists = inhists;
  end
  
  for kk=1:numel(hists)
    
    h = hists(kk);
    
    % fit plistUsed
    processPlistUsed(h.plistUsed, hists, uuids);
    
  end
  
  
end


function processPlistUsed(pl, hists, uuids)
  
  for kk=1:length(pl.params)
    
    val = pl.params(kk).getVal();
    %fprintf('* processing value type %s\n', class(val));
    
    if iscell(val)
      
      oval = [];
      for vv=1:numel(val)
        cellval = val{vv};
        %fprintf('   element %d is a %s\n', vv, class(cellval));
        
        if iscellstr(cellval)
          % If we have a cell-array of strings, this converts back to an
          % array of objects
          ocellval = [];
          for cc=1:numel(cellval)
            idx = strcmp(cellval{cc}, uuids);
            if any(idx)
              %fprintf('       replacing indices %s\n', mat2str(find(idx)));
              ocellval = [ocellval hists(idx)];
            end
          end
          
          val{vv} = ocellval;
          
        elseif ischar(cellval)
          % element is a string and should/could convert to an object
          idx = strcmp(cellval, uuids);
          if any(idx)
            %fprintf('       replacing indices %s\n', mat2str(find(idx)));
            oval = [oval hists(idx)];
          end
          
        else
          % do nothing
        end
      end
      
      if ~isempty(oval)
        val = oval;
      end
      
    end
    
    pl.params(kk).setVal(val);
    
  end
  
end

% END