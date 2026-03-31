
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty specwin node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      specwinNode = dom.createElement('specwin');
      specwinNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, specwinNode, collectedHist);
      
      % Add type
      childNode = dom.createElement('type');
      utils.xml.attachCharToDom(obj.type, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add alpha
      childNode = dom.createElement('alpha');
      utils.xml.attachNumberToDom(obj.alpha, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add psll
      childNode = dom.createElement('psll');
      utils.xml.attachNumberToDom(obj.psll, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add rov
      childNode = dom.createElement('rov');
      utils.xml.attachNumberToDom(obj.rov, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add nenbw
      childNode = dom.createElement('nenbw');
      utils.xml.attachNumberToDom(obj.nenbw, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add w3db
      childNode = dom.createElement('w3db');
      utils.xml.attachNumberToDom(obj.w3db, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add flatness
      childNode = dom.createElement('flatness');
      utils.xml.attachNumberToDom(obj.flatness, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add levelorder
      childNode = dom.createElement('levelorder');
      utils.xml.attachNumberToDom(obj.levelorder, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add skip
      childNode = dom.createElement('skip');
      utils.xml.attachNumberToDom(obj.skip, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add len
      childNode = dom.createElement('len');
      utils.xml.attachNumberToDom(obj.len, dom, childNode)
      specwinNode.appendChild(childNode);
      
      % Add to parent node
      parent.appendChild(specwinNode);
      
    end
  end
  
end
