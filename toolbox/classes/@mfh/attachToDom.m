
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % create empty mfir node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % create object node
      mfhNode = dom.createElement('mfh');
      mfhNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, mfhNode, collectedHist);
      
      % add funcDef
      node = dom.createElement('funcDef');
      utils.xml.attachCharToDom(obj.funcDef, dom, node);
      mfhNode.appendChild(node);
      
      % add paramsDef
      if ~isempty(obj.paramsDef)
        node = dom.createElement('paramsDef');
        collectedHist = obj.paramsDef.attachToDom(dom, node, collectedHist);
        mfhNode.appendChild(node);
      end
      
      % add func
      node = dom.createElement('func');
      utils.xml.attachCharToDom(obj.func, dom, node);
      mfhNode.appendChild(node);
      
      % Add subfuncs
      if isa(obj.subfuncs, 'mfh')
        subfuncsNode = dom.createElement('subfuncs');
        collectedHist = obj.subfuncs.attachToDom(dom, subfuncsNode, collectedHist);
        mfhNode.appendChild(subfuncsNode);
      end
      
      % Add inputs
      inputsNode = dom.createElement('inputs');
      utils.xml.attachCellstrToDom(obj.inputs, dom, inputsNode);
      mfhNode.appendChild(inputsNode);
      
      % Add inputObjects
      inputObjectsNode = dom.createElement('inputObjects');
      collectedHist = utils.xml.attachCellToDom(obj.inputObjects, dom, inputObjectsNode, collectedHist);
      mfhNode.appendChild(inputObjectsNode);
      
      % Add constants
      constantsNode = dom.createElement('constants');
      utils.xml.attachCellToDom(obj.constants, dom, constantsNode, collectedHist);
      mfhNode.appendChild(constantsNode);
      
      % Add numeric
      numericNode = dom.createElement('numeric');
      utils.xml.attachNumberToDom(obj.numeric, dom, numericNode);
      mfhNode.appendChild(numericNode);
      
      % Add constObjects
      constObjectsNode = dom.createElement('constObjects');
      collectedHist = utils.xml.attachCellToDom(obj.constObjects, dom, constObjectsNode, collectedHist);
      mfhNode.appendChild(constObjectsNode);
      
      % add to parent node
      parent.appendChild(mfhNode);
      
    end
  end
  
end
