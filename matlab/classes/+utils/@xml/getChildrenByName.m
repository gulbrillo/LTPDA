
function result = getChildrenByName(node, childName)
  
  persistent FACTORY
  persistent XPATH
  
  if isempty(FACTORY)
    FACTORY = javax.xml.xpath.XPathFactory.newInstance();
  end
  if isempty(XPATH)
    XPATH   = FACTORY.newXPath();
  end
  
  expression = XPATH.compile(sprintf('child::%s', childName));
  result = expression.evaluate(node, javax.xml.xpath.XPathConstants.NODESET);
  
end
