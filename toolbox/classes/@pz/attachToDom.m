
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty pz node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      pzNode = dom.createElement('pz');
      pzNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, pzNode, collectedHist);
      
      % Add f
      pzNode.setAttribute('f', utils.xml.mat2str(obj.f))
      
      % Add q
      pzNode.setAttribute('q', utils.xml.mat2str(obj.q))
      
      % Add ri
      pzNode.setAttribute('ri', utils.xml.mat2str(obj.ri))
      
      % Add to parent node
      parent.appendChild(pzNode);
      
    end
  end
  
end
