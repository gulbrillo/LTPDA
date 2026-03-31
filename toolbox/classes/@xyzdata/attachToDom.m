
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty xyzdata node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      xyzdataNode = dom.createElement('xyzdata');
      xyzdataNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@data3D(obj, dom, xyzdataNode, collectedHist);
      
      % Add to parent node
      parent.appendChild(xyzdataNode);
      
    end
  end
  
end
