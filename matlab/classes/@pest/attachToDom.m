
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty pest node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      pestNode = dom.createElement('pest');
      pestNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_uoh(obj, dom, pestNode, collectedHist);
      
      % Add dy
      dyNode = dom.createElement('dy');
      utils.xml.attachNumberToDom(obj.dy, dom, dyNode);
      pestNode.appendChild(dyNode);
      
      % Add y
      yNode = dom.createElement('y');
      utils.xml.attachNumberToDom(obj.y, dom, yNode);
      pestNode.appendChild(yNode);
      
      % Add names
      content = dom.createTextNode(utils.xml.cellstr2str(obj.names));
      namesNode = dom.createElement('names');
      namesNode.appendChild(content);
      pestNode.appendChild(namesNode);
      
      % Add yunits
      if isa(obj.yunits, 'unit')
        yunitsNode = dom.createElement('yunits');
        collectedHist = obj.yunits.attachToDom(dom, yunitsNode, collectedHist);
        pestNode.appendChild(yunitsNode);
      end
      
      % Add pdf
      pdfNode = dom.createElement('pdf');
      utils.xml.attachNumberToDom(obj.pdf, dom, pdfNode);
      pestNode.appendChild(pdfNode);
      
      % Add cov
      covNode = dom.createElement('cov');
      utils.xml.attachNumberToDom(obj.cov, dom, covNode);
      pestNode.appendChild(covNode);
      
      % Add corr
      corrNode = dom.createElement('corr');
      utils.xml.attachNumberToDom(obj.corr, dom, corrNode);
      pestNode.appendChild(corrNode);
      
      % Add chi2
      chi2Node = dom.createElement('chi2');
      utils.xml.attachNumberToDom(obj.chi2, dom, chi2Node);
      pestNode.appendChild(chi2Node);
      
      % Add dof
      dofNode = dom.createElement('dof');
      utils.xml.attachNumberToDom(obj.dof, dom, dofNode);
      pestNode.appendChild(dofNode);
      
      % Add chain
      chainNode = dom.createElement('chain');
      utils.xml.attachNumberToDom(obj.chain, dom, chainNode);
      pestNode.appendChild(chainNode);
      
      % Add models
      if isa(obj.models, 'ltpda_obj')
        modelsNode = dom.createElement('models');
        collectedHist = obj.models.attachToDom(dom, modelsNode, collectedHist);
        pestNode.appendChild(modelsNode);
      end
      
      % Add to parent node
      parent.appendChild(pestNode);
      
    end
  end
  
end
