
function objs = getObject(node, inhists)
  
  objs = [];
  objShape = [0 0];
  for jj = 1:node.getLength
    
    childNode = node.item(jj-1);
    if childNode.getNodeType == childNode.ELEMENT_NODE
      
      className = utils.xml.mchar(childNode.getNodeName());
      objShape  = utils.xml.getShape(childNode);
      
      objs = [objs feval(className, childNode, inhists)];
    end
  end
  objs = reshape(objs, objShape);
  
end
