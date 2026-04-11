
function attachCharToDom(str, dom, parent)
  
  % Store the original shape of the string
  parent.setAttribute('shape', sprintf('%dx%d', size(str)));

  % Replace new line characters and cvs tags with wildcards and reshape the
  % string to one line
  str = utils.xml.prepareString(str);
  
  % Attach the string as a content to the parent node
  content = dom.createTextNode(str);
  parent.appendChild(content);
    
end
