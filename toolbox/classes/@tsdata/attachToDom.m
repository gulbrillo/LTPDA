
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty tsdata node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      tsdataNode = dom.createElement('tsdata');
      tsdataNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@data2D(obj, dom, tsdataNode, collectedHist);
      
      % Add t0
      if isa(obj.t0, 'time')
        childNode = dom.createElement('t0');
        
        % We keep the meaning of t0 for backwars compatibility. This means
        % - before saving, t0 = t0 + toffset
        % - after loading, t0 = t0 - toffset
        newT0 = obj.t0 + obj.toffset/1e3;
        
        collectedHist = newT0.attachToDom(dom, childNode, collectedHist);
        tsdataNode.appendChild(childNode);
      end
      
      % Add toffset
      childNode = dom.createElement('toffset');
      utils.xml.attachNumberToDom(obj.toffset, dom, childNode)
      tsdataNode.appendChild(childNode);
      
      % Add fs
      childNode = dom.createElement('fs');
      utils.xml.attachNumberToDom(obj.fs, dom, childNode)
      tsdataNode.appendChild(childNode);
      
      % Add nsecs
      childNode = dom.createElement('nsecs');
      utils.xml.attachNumberToDom(obj.nsecs, dom, childNode)
      tsdataNode.appendChild(childNode);
      
      % Add to parent node
      parent.appendChild(tsdataNode);
      
    end
  end
  
end
