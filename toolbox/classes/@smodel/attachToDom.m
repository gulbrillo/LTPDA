
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty smodel node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      smodelNode = dom.createElement('smodel');
      smodelNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, smodelNode, collectedHist);
      
      % Add expression
      if ~isempty(obj.expr)
        exprNode = dom.createElement('expr');
        utils.xml.attachCharToDom(obj.expr.s, dom, exprNode);
        smodelNode.appendChild(exprNode);
      end
      
      % Add parameters
      content = dom.createTextNode(utils.xml.cellstr2str(obj.params));
      paramsNode = dom.createElement('params');
      paramsNode.appendChild(content);
      smodelNode.appendChild(paramsNode);
      
      % Add default values for the parameters
      valuesNode = dom.createElement('values');
      collectedHist = utils.xml.attachCellToDom(obj.values, dom, valuesNode, collectedHist);
      smodelNode.appendChild(valuesNode);
      
      % Add default trans for the parameters
      transNode = dom.createElement('trans');
      if ischar(obj.trans) || isnumeric(obj.trans)
        utils.xml.attachCharToDom(num2str(obj.trans), dom, transNode);
        transNode.setAttribute('type', 'char');
      elseif iscell(obj.trans)
        transNode = dom.createElement('trans');
        collectedHist = utils.xml.attachCellToDom(obj.trans, dom, transNode, collectedHist);
        transNode.setAttribute('type', 'cell');
      end
      smodelNode.appendChild(transNode);
      
      % Add x-variable
      xvarNode = dom.createElement('xvar');      
      if ischar(obj.xvar)
        utils.xml.attachCharToDom(obj.xvar, dom, xvarNode);
        xvarNode.setAttribute('type', 'char');
      elseif iscellstr(obj.xvar)
        content = dom.createTextNode(utils.xml.cellstr2str(obj.xvar));
        xvarNode.appendChild(content);
        xvarNode.setAttribute('type', 'cellstr');
      else
        error('### Unexpected values in xvar. %s', class(obj.xvar));
      end
      smodelNode.appendChild(xvarNode);
      
      % Add values for the x-variable
      if ~isempty(obj.xvals)
        xvalsNode = dom.createElement('xvals');
        collectedHist = utils.xml.attachCellToDom(obj.xvals, dom, xvalsNode, collectedHist);
        smodelNode.appendChild(xvalsNode);
      end
      
      % Add units of the x-axis
      if isa(obj.xunits, 'unit')
        xunitsNode = dom.createElement('xunits');
        collectedHist = obj.xunits.attachToDom(dom, xunitsNode, collectedHist);
        smodelNode.appendChild(xunitsNode);
      end
      
      % Add units of the y-axis
      if isa(obj.yunits, 'unit')
        yunitsNode = dom.createElement('yunits');
        collectedHist = obj.yunits.attachToDom(dom, yunitsNode, collectedHist);
        smodelNode.appendChild(yunitsNode);
      end
      
      % Add aliasNames
      if ~isempty(obj.aliasNames)
        aliasNamesNode = dom.createElement('aliasNames');
        collectedHist = utils.xml.attachCellToDom(obj.aliasNames, dom, aliasNamesNode, collectedHist);
        smodelNode.appendChild(aliasNamesNode);
      end
      
      % Add aliasValues
      if ~isempty(obj.aliasValues)
        aliasValuesNode = dom.createElement('aliasValues');
        collectedHist = utils.xml.attachCellToDom(obj.aliasValues, dom, aliasValuesNode, collectedHist);
        smodelNode.appendChild(aliasValuesNode);
      end
      
      % Add to parent node
      parent.appendChild(smodelNode);
      
    end
  end
  
end
