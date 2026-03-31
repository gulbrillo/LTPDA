
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@data2D(obj, dom, parent, collectedHist);
  
  % Add zaxis
  axisNode = dom.createElement('zaxis');
  collectedHist = obj.zaxis.attachToDom(dom, axisNode, collectedHist);
  parent.appendChild(axisNode);
  
end
