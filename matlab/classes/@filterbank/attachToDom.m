
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty filterbank node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      filterbankNode = dom.createElement('filterbank');
      filterbankNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, filterbankNode, collectedHist);
      
      % Add filters
      if isa(obj.filters, 'ltpda_filter')
        filtersNode = dom.createElement('filters');
        collectedHist = obj.filters.attachToDom(dom, filtersNode, collectedHist);
        filterbankNode.appendChild(filtersNode);
      end
      
      % Add type
      typeNode = dom.createElement('type');
      utils.xml.attachCharToDom(obj.type, dom, typeNode);
      filterbankNode.appendChild(typeNode);
      
      % Add to parent node
      parent.appendChild(filterbankNode);
      
    end
  end
  
end
