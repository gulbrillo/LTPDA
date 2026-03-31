
function s = prepareVersionString(s)
  
  s = strrep(s, '$Id', utils.xml.WILDCARD_CVS);
  
end
