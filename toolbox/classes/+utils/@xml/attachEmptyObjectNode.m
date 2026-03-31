
function attachEmptyObjectNode(objs, dom, parent)
  
    emptyNode = dom.createElement(class(objs));
    emptyNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
    % Add to parent node
    parent.appendChild(emptyNode);  
  
end