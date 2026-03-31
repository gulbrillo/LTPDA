
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty cdata node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      cdataNode = dom.createElement('cdata');
      cdataNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_data(obj, dom, cdataNode, collectedHist);
      
      % Add to parent node
      parent.appendChild(cdataNode);
      
    end
  end
  
end
