
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_nuo(obj, dom, parent, collectedHist);
  
  % Add name
  parent.setAttribute('name', obj.name);
  
  % Add data
  dataNode = dom.createElement('data');
  utils.xml.attachNumberToDom(obj.data, dom, dataNode)
  parent.appendChild(dataNode);
  
  % Add ddata
  ddataNode = dom.createElement('ddata');
  utils.xml.attachNumberToDom(obj.ddata, dom, ddataNode)
  parent.appendChild(ddataNode);
  
  % Add units
  if isa(obj.units, 'unit')
    unitsNode = dom.createElement('units');
    collectedHist = obj.units.attachToDom(dom, unitsNode, collectedHist);
    parent.appendChild(unitsNode);
  end
  
end
