
function attachSymToDom(obj, dom, parent)
  
  % Attach the string as a content to the parent node
  content = dom.createTextNode(char(obj));
  parent.appendChild(content);
  
end
