
function collectedHist = attachCellToDom(objs, dom, parent, collectedHist)
  
  % Store the cell shape in the parent node
  parent.setAttribute('cellShape', sprintf('%dx%d', size(objs)));
  parent.setAttribute('type', class(objs));

  if isempty(objs)
    
    % Create cell node
    cellNode = dom.createElement('cell');
    cellNode.setAttribute('cellShape', sprintf('%dx%d', size(objs)));
    cellNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
    cellNode.setAttribute('type', 'empty-cell');
    
    % Add to parent node
    parent.appendChild(cellNode);
    
  else
    
    for oo = 1:numel(objs)
      obj = objs{oo};
      
      % Create cell node
      cellNode = dom.createElement('cell');
      
      % It is necessary to add 'cellShape' to a cell node because
      % attachNumberToDom overwrites the attribute 'shape' (in some cases)
      cellNode.setAttribute('cellShape', sprintf('%dx%d', size(objs)));
      cellNode.setAttribute('shape', sprintf('%dx%d', size(obj)));
      cellNode.setAttribute('type', class(obj));
      
      if isnumeric(obj)
        
        utils.xml.attachNumberToDom(obj, dom, cellNode);
        
      elseif islogical(obj)
        content = dom.createTextNode(utils.xml.mat2str(obj));
        cellNode.appendChild(content);
        
      elseif isa(obj, 'sym')
        utils.xml.attachSymToDom(obj, dom, cellNode);
        
      elseif ischar(obj)
        utils.xml.attachCharToDom(obj, dom, cellNode);
        
      elseif isa(obj, 'history')
        
        % A special case for attaching history objects to the DOM (Document
        % Object Model) because the history objects have their own section
        % in the XML. For this is it necessary to store the UUID of the
        % history object inside the attribute 'val' and later the read
        % process gets the right history object for this UUID.
        %
        % We use the same behaviour for PLISTS and that is the reason why
        % the attribute name is 'val'.
        %
        cellNode.setAttribute('val', strtrim(sprintf('%s ', obj.UUID)));
        collectedHist = obj.attachToDom(dom, cellNode, collectedHist);
        
      elseif isa(obj, 'ltpda_obj')
        collectedHist = obj.attachToDom(dom, cellNode, collectedHist);
        
      elseif iscell(obj)
        collectedHist = utils.xml.attachCellToDom(obj, dom, cellNode, collectedHist);
        
      elseif isstruct(obj)
        collectedHist = utils.xml.attachStructToDom(obj, dom, cellNode, collectedHist);
        
      elseif isjava(obj)
        if strcmp(class(obj), 'sun.util.calendar.ZoneInfo')
          content = dom.createTextNode(char(obj.getID));
          cellNode.appendChild(content);
        else
          error('### Unknown JAVA class. Can not attach the java class %s to DOM.', class(obj));
        end
        
      else
        error('!!! Please code me up for the class [%s]', class(obj));
      end
      
      % Add to parent node
      parent.appendChild(cellNode);
      
    end
    
  end
  
end
