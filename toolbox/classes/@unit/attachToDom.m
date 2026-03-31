
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty unit node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      appendChild = true;
      % Don't create a unit node if the method is called by one of the
      % properties: xunits, yunits, ounits, iunits
      % Remark: This is only possible if the propertie have only one unit
      %         object
      nodeName = utils.xml.mchar(parent.getNodeName);
      if ~isempty(regexp(nodeName, '.units', 'match')) && numel(objs) == 1
        unitNode = parent;
        appendChild = false;
      else
        % Create object node
        unitNode = dom.createElement('unit');
      end
      
      % Set shape
      unitNode.setAttribute('shape', sprintf('%dx%d', size(objs)));

      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, unitNode, collectedHist);
      
      % Add strs
      unitNode.setAttribute('strs', utils.xml.cellstr2str(obj.strs));
      
      % Add exps
      unitNode.setAttribute('exps', utils.xml.mat2str(obj.exps));
      
      % Add vals
      unitNode.setAttribute('vals', utils.xml.mat2str(obj.vals));
      
      % Add to parent node
      if appendChild
        parent.appendChild(unitNode);
      end
      
    end
  end
  
end
