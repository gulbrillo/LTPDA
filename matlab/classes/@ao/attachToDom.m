
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ao node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      aoNode = dom.createElement('ao');
      aoNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, aoNode, collectedHist);
      
      % Add data
      if isa(obj.data, 'ltpda_data')
        dataNode = dom.createElement('data');
        collectedHist = obj.data.attachToDom(dom, dataNode, collectedHist);
        aoNode.appendChild(dataNode);
      end
      
      % Add to parent node
      parent.appendChild(aoNode);
      
    end
  end
  
end
