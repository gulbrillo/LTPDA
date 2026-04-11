
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_data(obj, dom, parent, collectedHist);
  
  % Add xaxis
  xaxisNode = dom.createElement('xaxis');
  collectedHist = obj.xaxis.attachToDom(dom, xaxisNode, collectedHist);
  parent.appendChild(xaxisNode);
  
end
