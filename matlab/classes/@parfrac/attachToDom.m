
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty parfrac node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      parfracNode = dom.createElement('parfrac');
      parfracNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_tf(obj, dom, parfracNode, collectedHist);
      
      % Add res
      resNode = dom.createElement('res');
      utils.xml.attachNumberToDom(obj.res, dom, resNode)
      parfracNode.appendChild(resNode);
      
      % Add poles
      polesNode = dom.createElement('poles');
      utils.xml.attachNumberToDom(obj.poles, dom, polesNode)
      parfracNode.appendChild(polesNode);
      
      % Add pmul
      pmulNode = dom.createElement('pmul');
      utils.xml.attachNumberToDom(obj.pmul, dom, pmulNode)
      parfracNode.appendChild(pmulNode);
      
      % Add dir
      dirNode = dom.createElement('dir');
      utils.xml.attachNumberToDom(obj.dir, dom, dirNode)
      parfracNode.appendChild(dirNode);
      
      % Add to parent node
      parent.appendChild(parfracNode);
      
    end
  end
  
end
