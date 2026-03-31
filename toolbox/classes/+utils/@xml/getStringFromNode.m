function str = getStringFromNode(node)
  
  str = utils.xml.mchar(node.getTextContent);
  
end