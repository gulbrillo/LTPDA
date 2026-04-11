
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ssm node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      ssmNode = dom.createElement('ssm');
      ssmNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, ssmNode, collectedHist);
      
      % Add amats
      amatsNode = dom.createElement('amats');
      collectedHist = utils.xml.attachCellToDom(obj.amats, dom, amatsNode, collectedHist);
      ssmNode.appendChild(amatsNode);
      
      % Add bmats
      bmatsNode = dom.createElement('bmats');
      collectedHist = utils.xml.attachCellToDom(obj.bmats, dom, bmatsNode, collectedHist);
      ssmNode.appendChild(bmatsNode);
      
      % Add cmats
      cmatsNode = dom.createElement('cmats');
      collectedHist = utils.xml.attachCellToDom(obj.cmats, dom, cmatsNode, collectedHist);
      ssmNode.appendChild(cmatsNode);
      
      % Add dmats
      dmatsNode = dom.createElement('dmats');
      collectedHist = utils.xml.attachCellToDom(obj.dmats, dom, dmatsNode, collectedHist);
      ssmNode.appendChild(dmatsNode);
      
      % Add timestep
      timestepNode = dom.createElement('timestep');
      utils.xml.attachNumberToDom(obj.timestep, dom, timestepNode);
      ssmNode.appendChild(timestepNode);
      
      % Add inputs
      if isa(obj.inputs, 'ltpda_obj')
        inputsNode = dom.createElement('inputs');
        collectedHist = obj.inputs.attachToDom(dom, inputsNode, collectedHist);
        ssmNode.appendChild(inputsNode);
      end
      
      % Add states
      if isa(obj.states, 'ltpda_obj')
        statesNode = dom.createElement('states');
        collectedHist = obj.states.attachToDom(dom, statesNode, collectedHist);
        ssmNode.appendChild(statesNode);
      end
      
      % Add outputs
      if isa(obj.outputs, 'ltpda_obj')
        outputsNode = dom.createElement('outputs');
        collectedHist = obj.outputs.attachToDom(dom, outputsNode, collectedHist);
        ssmNode.appendChild(outputsNode);
      end
      
      % Add numparams
      if isa(obj.numparams, 'ltpda_obj')
        numparamsNode = dom.createElement('numparams');
        collectedHist = obj.numparams.attachToDom(dom, numparamsNode, collectedHist);
        ssmNode.appendChild(numparamsNode);
      end
      
      % Add params
      if isa(obj.params, 'ltpda_obj')
        paramsNode = dom.createElement('params');
        collectedHist = obj.params.attachToDom(dom, paramsNode, collectedHist);
        ssmNode.appendChild(paramsNode);
      end
      
      % Add to parent node
      parent.appendChild(ssmNode);
      
    end
  end
  
end
