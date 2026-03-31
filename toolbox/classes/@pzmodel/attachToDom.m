
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty pzmodel node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      pzmodelNode = dom.createElement('pzmodel');
      pzmodelNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_tf(obj, dom, pzmodelNode, collectedHist);
      
      % Add poles
      if isa(obj.poles, 'pz')
        polesNode = dom.createElement('poles');
        collectedHist = obj.poles.attachToDom(dom, polesNode, collectedHist);
        pzmodelNode.appendChild(polesNode);
      end
      
      % Add zeros
      if isa(obj.zeros, 'pz')
        zerosNode = dom.createElement('zeros');
        collectedHist = obj.zeros.attachToDom(dom, zerosNode, collectedHist);
        pzmodelNode.appendChild(zerosNode);
      end
      
      % Add gain
      gainNode = dom.createElement('gain');
      utils.xml.attachNumberToDom(obj.gain, dom, gainNode)
      pzmodelNode.appendChild(gainNode);
      
      % Add delay
      delayNode = dom.createElement('delay');
      utils.xml.attachNumberToDom(obj.delay, dom, delayNode)
      pzmodelNode.appendChild(delayNode);
      
      % Add to parent node
      parent.appendChild(pzmodelNode);
      
    end
  end
  
end
