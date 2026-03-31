

function str = getSym(node)
  
  % Get node content
  str = utils.xml.mchar(node.getTextContent());  
  % Convert to 'sym'
  str = sym(str);
  
end

