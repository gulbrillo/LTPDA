
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ssmblock node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      ssmblockNode = dom.createElement('ssmblock');
      ssmblockNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, ssmblockNode, collectedHist);
      
      % Add name
      if ~isempty(obj.name)
        nameNode = dom.createElement('name');
        utils.xml.attachCharToDom(obj.name, dom, nameNode);
        ssmblockNode.appendChild(nameNode);
      end
      
      % Add ports
      if isa(obj.ports, 'ssmport')
        portsNode = dom.createElement('ports');
        collectedHist = obj.ports.attachToDom(dom, portsNode, collectedHist);
        ssmblockNode.appendChild(portsNode);
      end
      
      % Add description
      if ~isempty(obj.description)
        descriptionNode = dom.createElement('description');
        utils.xml.attachCharToDom(obj.description, dom, descriptionNode);
        ssmblockNode.appendChild(descriptionNode);
      end
      
      % Add to parent node
      parent.appendChild(ssmblockNode);
      
    end
  end
  
end
