
function type = getType(node)
  
  type = '';
  if node.hasAttribute('type')
    type = utils.xml.mchar(node.getAttribute('type'));
  end
  
end
