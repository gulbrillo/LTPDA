
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_uoh(obj, dom, parent, collectedHist);
  
  % Add iunits
  if isa(obj.iunits, 'unit')
    iunitsNode = dom.createElement('iunits');
    collectedHist = obj.iunits.attachToDom(dom, iunitsNode, collectedHist);
    parent.appendChild(iunitsNode);
  end
  
  % Add ounits
  if isa(obj.ounits, 'unit')
    ounitsNode = dom.createElement('ounits');
    collectedHist = obj.ounits.attachToDom(dom, ounitsNode, collectedHist);
    parent.appendChild(ounitsNode);
  end
  
end
