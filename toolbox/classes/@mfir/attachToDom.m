
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % create empty mfir node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % create object node
      mfirNode = dom.createElement('mfir');
      mfirNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % call superclass
      collectedHist = attachToDom@ltpda_filter(obj, dom, mfirNode, collectedHist);
      
      % add histout
      gdNode = dom.createElement('gd');
      utils.xml.attachNumberToDom(obj.gd, dom, gdNode);
      mfirNode.appendChild(gdNode);
      
      % add to parent node
      parent.appendChild(mfirNode);
      
    end
  end
  
end
