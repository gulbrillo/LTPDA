function objs = loadobj(objs)
  
  for oo=1:numel(objs)
    obj = objs(oo);
    
    if isempty(obj.historyArray) && isa(obj.hist, 'history')
      % This is an old-type ltpda object from disk, so we don't need to
      % expand the history.
      continue
    end
    if isempty(obj.hist)
      % It is possible that LTPDA objects contain other LTPDA objects
      % which doesn't have any history.
      continue
    end
    
    rootNodeUUID = obj.hist;
    hists = obj.historyArray;
    
    uuids = expandHistory(hists);
    
    idx = strcmp(rootNodeUUID, uuids);
    obj.hist = hists(idx);
    obj.historyArray = [];
  end
  
end

% END
