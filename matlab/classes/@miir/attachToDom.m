
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty miir node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      miirNode = dom.createElement('miir');
      miirNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_filter(obj, dom, miirNode, collectedHist);
      
      % Add b
      bNode = dom.createElement('b');
      utils.xml.attachNumberToDom(obj.b, dom, bNode);
      miirNode.appendChild(bNode);
      
      % Add histout
      histinNode = dom.createElement('histin');
      utils.xml.attachNumberToDom(obj.histin, dom, histinNode);
      miirNode.appendChild(histinNode);
      
      % Add to parent node
      parent.appendChild(miirNode);
      
    end
  end
  
end
