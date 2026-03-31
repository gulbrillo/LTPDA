
function h = getHistoryFromUUID(hists, inhistUUID)
  
  h = [];
  for ii = 1:numel(hists)
    if strcmp(hists(ii).UUID, inhistUUID)
      h = hists(ii);
      break;
    end
  end
  
  if isempty(h)
    error('### Didn''t find a history object with the UUID [%s]', inhistUUID)
  end
  
end
