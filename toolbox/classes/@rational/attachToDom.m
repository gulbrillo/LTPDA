
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty rational node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      rationalNode = dom.createElement('rational');
      rationalNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_tf(obj, dom, rationalNode, collectedHist);
      
      % Add num
      numNode = dom.createElement('num');
      utils.xml.attachNumberToDom(obj.num, dom, numNode)
      rationalNode.appendChild(numNode);
      
      % Add den
      denNode = dom.createElement('den');
      utils.xml.attachNumberToDom(obj.den, dom, denNode)
      rationalNode.appendChild(denNode);
      
      % Add to parent node
      parent.appendChild(rationalNode);
      
    end
  end
  
end
