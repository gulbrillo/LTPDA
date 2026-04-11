
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty plist node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      appendChild = true;
      % Don't create a plist node if the method is called by the history
      % property 'plistUsed'
      % Remark: This is only possible if the propertie have only one plist
      %         object
      nodeName = utils.xml.mchar(parent.getNodeName);
      if strcmp(nodeName, 'plistUsed') && numel(objs) == 1
        plistNode = parent;
        appendChild = false;
      else
        % Create object node
        plistNode = dom.createElement('plist');
      end

      % Set shape
      plistNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uo(obj, dom, plistNode, collectedHist);
      
      % Add params
      if isa(obj.params, 'param')
        collectedHist = obj.params.attachToDom(dom, plistNode, collectedHist);
      end
            
      % Add to parent node
      if appendChild
        parent.appendChild(plistNode);
      end
      
    end
  end
  
end
