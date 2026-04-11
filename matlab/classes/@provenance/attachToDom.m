
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty provenance node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      provenanceNode = dom.createElement('provenance');
      provenanceNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      provenanceNode.setAttribute('creator', obj.getEncodedString);
      
      % Add to parent node
      parent.appendChild(provenanceNode);
    end
  end
  
end
