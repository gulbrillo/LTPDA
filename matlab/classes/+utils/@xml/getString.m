
function str = getString(node)
  
  % Get node content
  str   = utils.xml.recoverString(node.getTextContent());  
  % Get the shape from the attribute
  shape = utils.xml.getShape(node);
  
  str = reshape(str, shape);
  
end

