
function s = recoverVersionString(jString)
  
  if isa(jString, 'java.lang.String')
    s = utils.xml.mchar(jString);
  else
    s = jString;
  end
  
  s = strrep(s, utils.xml.WILDCARD_CVS, '$Id');
  
end
