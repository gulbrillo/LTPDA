
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ssmport node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      ssmportNode = dom.createElement('ssmport');
      ssmportNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, ssmportNode, collectedHist);
      
      % Add name
      if ~isempty(obj.name)
        nameNode = dom.createElement('name');
        utils.xml.attachCharToDom(obj.name, dom, nameNode);
        ssmportNode.appendChild(nameNode);
      end
      
      % Add units
      if isa(obj.units, 'unit')
        unitsNode = dom.createElement('units');
        collectedHist = obj.units.attachToDom(dom, unitsNode, collectedHist);
        ssmportNode.appendChild(unitsNode);
      end
      
      % Add description
      if ~isempty(obj.description)
        descriptionNode = dom.createElement('description');
        utils.xml.attachCharToDom(obj.description, dom, descriptionNode);
        ssmportNode.appendChild(descriptionNode);
      end
      
      % Add to parent node
      parent.appendChild(ssmportNode);
      
    end
  end
  
end
