
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty ao node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      mcmcNode = dom.createElement('MCMC');
      mcmcNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, mcmcNode, collectedHist);
          
      % Add package
      mcmcNode.setAttribute('PACKAGE', obj.package);
      
      % Add package
      mcmcNode.setAttribute('CATEGORY', obj.category);
      
      % Add params
      if isa(obj.params, 'plist')
        newNode = dom.createElement('params');
        collectedHist = obj.params.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add model
      if isa(obj.model, 'mfh') || isa(obj.model, 'ssm')
        newNode = dom.createElement('model');
        collectedHist = obj.model.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add inputs
      if isa(obj.inputs, 'ao') || isa(obj.inputs, 'matrix')
        newNode = dom.createElement('inputs');
        collectedHist = obj.inputs.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add outputs
      if isa(obj.outputs, 'ao') || isa(obj.outputs, 'matrix')
        newNode = dom.createElement('outputs');
        collectedHist = obj.outputs.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add noise
      if isa(obj.noise, 'ao') || isa(obj.noise, 'matrix')
        newNode = dom.createElement('noise');
        collectedHist = obj.noise.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add covariance
      if isa(obj.covariance, 'ao')
        newNode = dom.createElement('covariance');
        collectedHist = obj.covariance.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      else
        newNode = dom.createElement('covariance');
        utils.xml.attachNumberToDom(obj.covariance, dom, newNode);
        mcmcNode.appendChild(newNode);
      end
      
      % Add dstep
       if isa(obj.diffStep, 'ao')
        newNode = dom.createElement('diffStep');
        collectedHist = obj.diffStep.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      else
        newNode = dom.createElement('diffStep');
        utils.xml.attachNumberToDom(obj.diffStep, dom, newNode);
        mcmcNode.appendChild(newNode);
       end
      
      % Add logParams
      newNode = dom.createElement('logParams');
      utils.xml.attachNumberToDom(obj.logParams, dom, newNode);
      mcmcNode.appendChild(newNode);
      
      % Add freqs
      newNode = dom.createElement('freqs');
      utils.xml.attachNumberToDom(obj.freqs, dom, newNode);
      mcmcNode.appendChild(newNode);
      
      % Add processedModel
      if isa(obj.processedModel, 'ssm')
        newNode = dom.createElement('processedModel');
        collectedHist = obj.processedModel.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add pest
      if isa(obj.pest, 'pest')
        newNode = dom.createElement('pest');
        collectedHist = obj.pest.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add loglikelihood
      if isa(obj.loglikelihood, 'mfh')
        newNode = dom.createElement('pest');
        collectedHist = obj.loglikelihood.attachToDom(dom, newNode, collectedHist);
        mcmcNode.appendChild(newNode);
      end
      
      % Add to parent node
      parent.appendChild(mcmcNode);
      
    end
  end
  
end
