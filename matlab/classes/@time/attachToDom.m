
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty time node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      timeNode = dom.createElement('time');
      timeNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, timeNode, collectedHist);
      
      % Add utc_epoch_milli
      timeNode.setAttribute('utc_epoch_milli', utils.xml.num2str(obj.utc_epoch_milli))
      
      % Add to parent node
      parent.appendChild(timeNode);
      
    end
  end
  
end
