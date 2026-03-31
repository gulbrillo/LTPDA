
function objs = getCell(node, inhists)

  % Get shape
  objShape = sscanf(utils.xml.mchar(node.getAttribute('cellShape')), '%dx%d')';
  
  if any(objShape==0)
    
    objs = cell(objShape);
    
  else
    
    objs = {};
    for jj = 1:node.getLength
      
      childNode = node.item(jj-1);
      if childNode.getNodeType == childNode.ELEMENT_NODE
        
        objs = [objs {utils.xml.getFromType(childNode, inhists)}];
        
      end
    end
    
    objs = reshape(objs, objShape);
    
  end

end
