
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty xydata node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      xydataNode = dom.createElement('xydata');
      xydataNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@data2D(obj, dom, xydataNode, collectedHist);
      
      % Add to parent node
      parent.appendChild(xydataNode);
      
    end
  end
  
end
