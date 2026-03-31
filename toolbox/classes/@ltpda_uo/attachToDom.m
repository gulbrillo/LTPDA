
function collectedHist = attachToDom(obj, dom, parent, collectedHist)
  
  collectedHist = attachToDom@ltpda_obj(obj, dom, parent, collectedHist);
  
  % Add name
  if ~isempty(obj.name)
    nameNode = dom.createElement('name');
    utils.xml.attachCharToDom(obj.name, dom, nameNode);
    parent.appendChild(nameNode);
  end
  
  % Add description
  if ~isempty(obj.description)
    descNode = dom.createElement('description');
    utils.xml.attachCharToDom(obj.description, dom, descNode);
    parent.appendChild(descNode);
  end
  
  % Add UUID
  parent.setAttribute('UUID', obj.UUID);
  
end
