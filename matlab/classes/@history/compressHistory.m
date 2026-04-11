% COMPRESSHISTORY returns an array of unique histories based on the input
% root node.
function hists = compressHistory(hist)
  
  % replace .hist tree with a flat array of histories
  
  [hists, ~] = getAllUniqueHistories(hist);
  
  for kk=1:numel(hists)
    if isa(hists(kk).inhists, 'history')
      hists(kk).inhists = {hists(kk).inhists.UUID};
    end
    
    % compress plistUsed
    pl = compressPlist(hists(kk).plistUsed);
    hists(kk).plistUsed = pl;
  end
  
end

% END