
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ltpda_minfo node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      
      obj = objs(oo);
      
      % Create object node
      minfoNode = dom.createElement('minfo');  % keep XML tag as 'minfo' for backward compat with saved files
      minfoNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Add encoded string
      minfoNode.setAttribute('methodInfo', obj.getEncodedString);
      
      % Add children
      if isa(obj.children, 'ltpda_minfo')
%         childrenNode = dom.createElement('children');
        collectedHist = obj.children.attachToDom(dom, minfoNode, collectedHist);
%         aoNode.appendChild(childrenNode);
      end
      
      % Add to parent node
      parent.appendChild(minfoNode);
    end
  end
  
end
