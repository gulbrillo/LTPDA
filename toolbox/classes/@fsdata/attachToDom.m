
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty fsdata node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      fsdataNode = dom.createElement('fsdata');
      fsdataNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@data2D(obj, dom, fsdataNode, collectedHist);
      
      % Add t0
      if isa(obj.t0, 'time')
        t0Node = dom.createElement('t0');
        collectedHist = obj.t0.attachToDom(dom, t0Node, collectedHist);
        fsdataNode.appendChild(t0Node);
      end
      
      % Add fs
      fsNode = dom.createElement('fs');
      utils.xml.attachNumberToDom(obj.fs, dom, fsNode)
      fsdataNode.appendChild(fsNode);
      
      % Add navs
      navsNode = dom.createElement('navs');
      utils.xml.attachNumberToDom(obj.navs, dom, navsNode)
      fsdataNode.appendChild(navsNode);
      
      % Add enbw
      enbwNode = dom.createElement('enbw');
      utils.xml.attachNumberToDom(obj.enbw, dom, enbwNode)
      fsdataNode.appendChild(enbwNode);
      
      % Add to parent node
      parent.appendChild(fsdataNode);
      
    end
  end
  
end
