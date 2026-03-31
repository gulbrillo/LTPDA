
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty plotinfo node
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      paramNode = dom.createElement('plotinfo');
      paramNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, paramNode, collectedHist);
      
      % Add style
      if ~isempty(obj.style)
        obj.style.attachToDom(dom, paramNode);
      end
      
      % Add includeInLegend
      paramNode.setAttribute('includeInLegend', num2str(obj.includeInLegend));
      
      % Add showErrors
      paramNode.setAttribute('showErrors', num2str(obj.showErrors));
      
      % Add axes - DON'T ADD, NEEDS SOME THOUGHT
      % Add figure - DON'T ADD, NEEDS SOME THOUGHT
      
      % Add to parent node
      parent.appendChild(paramNode);
      
    end
  end
  
end
