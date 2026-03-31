
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_nuo(obj, dom, parent, collectedHist);
  
  % Add yaxis
  yaxisNode = dom.createElement('yaxis');
  collectedHist = obj.yaxis.attachToDom(dom, yaxisNode, collectedHist);
  parent.appendChild(yaxisNode);
    
end
