
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty collection node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      collectionNode = dom.createElement('collection');
      collectionNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, collectionNode, collectedHist);
      
      % Add objs
      objsNode = dom.createElement('objs');
      collectedHist = utils.xml.attachCellToDom(obj.objs, dom, objsNode, collectedHist);
      collectionNode.appendChild(objsNode);
      
      % Add names
      namesNode = dom.createElement('names');
      collectedHist = utils.xml.attachCellToDom(obj.names, dom, namesNode, collectedHist);
      collectionNode.appendChild(namesNode);
      
      % Add to parent node
      parent.appendChild(collectionNode);
      
    end
  end
  
end
