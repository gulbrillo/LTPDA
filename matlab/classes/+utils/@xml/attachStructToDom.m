
function collectedHist = attachStructToDom(objs, dom, parent, collectedHist)
  
  % Store the structure shape in the parent node
  parent.setAttribute('structShape', sprintf('%dx%d', size(objs)));
  parent.setAttribute('type', class(objs));
  
  if isempty(objs)
    
    % Create structure node
    structNode = dom.createElement('struct');
    structNode.setAttribute('structShape', sprintf('%dx%d', size(objs)));
    structNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
    structNode.setAttribute('type', 'empty-struct');
    
    % Add to parent node
    parent.appendChild(structNode);
    
  else
    
    for oo = 1:numel(objs)
      obj = objs(oo);
      fnames = fieldnames(obj);
      
      % Create structure node
      structNode = dom.createElement('struct');
      structNode.setAttribute('structShape', sprintf('%dx%d', size(objs)));
      
      for ff=1:numel(fnames)
        val = obj.(fnames{ff});
        
        % Create structure node
        fieldnameNode = dom.createElement(fnames{ff});
        fieldnameNode.setAttribute('shape', sprintf('%dx%d', size(val)));
        fieldnameNode.setAttribute('type', class(val));

        if isnumeric(val)
          
          utils.xml.attachNumberToDom(val, dom, fieldnameNode);
          
        elseif islogical(val)
          content = dom.createTextNode(utils.xml.mat2str(val));
          fieldnameNode.appendChild(content);
          
        elseif isa(val, 'sym')
          utils.xml.attachSymToDom(val, dom, fieldnameNode);
          
        elseif ischar(val)
          utils.xml.attachCharToDom(val, dom, fieldnameNode);
          
        elseif isa(val, 'ltpda_obj')
          collectedHist = val.attachToDom(dom, fieldnameNode, collectedHist);
          
        elseif iscell(val)
          collectedHist = utils.xml.attachCellToDom(val, dom, fieldnameNode, collectedHist);
          
        elseif isstruct(val)
          collectedHist = utils.xml.attachStructToDom(val, dom, fieldnameNode, collectedHist);
          
        elseif isjava(val)
          if strcmp(class(val), 'sun.util.calendar.ZoneInfo')
            content = dom.createTextNode(char(val.getID));
            fieldnameNode.appendChild(content);
          else
            error('### Unknown JAVA class. Can not attach the java class %s to DOM.', class(val));
          end
          
        else
          error('!!! Please code me up for the class [%s]', class(val));
        end
        
        % Add fieldname node to structure node
        structNode.appendChild(fieldnameNode);
        
      end % ff=1:numel(fnames)
      
      % Add structure node to parent
      parent.appendChild(structNode);
      
    end % oo = 1:numel(objs)
    
  end
  
end
