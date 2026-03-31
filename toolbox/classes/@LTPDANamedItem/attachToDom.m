
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ao node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % if this is not a subclass, we need to add the parent node. Can't use
      % isa() here because that says true for all subclasses.
      objectIsSubclass = ~strcmp(class(obj), 'LTPDANamedItem');
      
      if ~objectIsSubclass
        % Create object node
        node = dom.createElement('LTPDANamedItem');
        node.setAttribute('shape', sprintf('%dx%d', size(objs)));
        
      else
        node = parent;
      end
      
      % Add name
      childNode = dom.createElement('name');
      utils.xml.attachCharToDom(obj.name, dom, childNode)
      node.appendChild(childNode);
      
      % Add description
      childNode = dom.createElement('description');
      utils.xml.attachCharToDom(obj.description, dom, childNode)
      node.appendChild(childNode);
      
      % Add units
      if isa(obj.units, 'unit')
        unitsNode = dom.createElement('units');
        collectedHist = obj.units.attachToDom(dom, unitsNode, collectedHist);
        node.appendChild(unitsNode);
      end
      
      if ~objectIsSubclass
        % Add to parent node
        parent.appendChild(node);
      end
    end
  end
  
end
