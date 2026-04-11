
function shape = getShape(node)
  
  if (node.hasAttribute('shape'))
    shape = sscanf(utils.xml.mchar(node.getAttribute('shape')), '%dx%d')';
  else
    error('### The node [%s] doesn''t have a attribute ''shape''', utils.xml.mchar(node.getNodeName()));
  end
  
end
