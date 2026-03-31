
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty minfo node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      
      obj = objs(oo);
      
      % Create object node
      minfoNode = dom.createElement('minfo');
      minfoNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Add encoded string
      minfoNode.setAttribute('methodInfo', obj.getEncodedString);
      
      % Add children
      if isa(obj.children, 'minfo')
%         childrenNode = dom.createElement('children');
        collectedHist = obj.children.attachToDom(dom, minfoNode, collectedHist);
%         aoNode.appendChild(childrenNode);
      end
      
      % Add to parent node
      parent.appendChild(minfoNode);
    end
  end
  
end
