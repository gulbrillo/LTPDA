
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty matrix node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      matrixNode = dom.createElement('matrix');
      matrixNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, matrixNode, collectedHist);
      
      % Add objs
      if isa(obj.objs, 'ltpda_obj')
        objsNode = dom.createElement('objs');
        collectedHist = obj.objs.attachToDom(dom, objsNode, collectedHist);
        matrixNode.appendChild(objsNode);
      end
      
      % Add to parent node
      parent.appendChild(matrixNode);
      
    end
  end
  
end
