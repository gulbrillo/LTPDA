
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty timespan node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      tsNode = dom.createElement('timespan');
      tsNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, tsNode, collectedHist);
      
      % Add startT
      startTNode = dom.createElement('startT');
      collectedHist = obj.startT.attachToDom(dom, startTNode, collectedHist);
      tsNode.appendChild(startTNode);
      
      % Add endT
      endTNode = dom.createElement('endT');
      collectedHist = obj.endT.attachToDom(dom, endTNode, collectedHist);
      tsNode.appendChild(endTNode);
      
      % Add to parent node
      parent.appendChild(tsNode);
    end
  end
  
end
