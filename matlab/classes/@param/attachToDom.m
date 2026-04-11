
function collectedHist = attachToDom(objs, dom, parent, collectedHist)
  
  if isempty(objs)
    
    % Create empty param node with the attribute 'shape'
    utils.xml.attachEmptyObjectNode(objs, dom, parent);
    
  else
    for oo = 1:numel(objs)
      obj = objs(oo);
      
      % Create object node
      paramNode = dom.createElement('param');
      paramNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
      
      % Call superclass
      collectedHist = attachToDom@ltpda_nuo(obj, dom, paramNode, collectedHist);
      
      % Add key
      paramNode.setAttribute('key', utils.helper.val2str(obj.key));
      
      % Add origin
      paramNode.setAttribute('origin', obj.origin);
      
      % Add param value
      val = obj.getVal;
      
      valNode = dom.createElement('val');
      valNode.setAttribute('shape', sprintf('%dx%d', size(val)));

      if isnumeric(val) || islogical(val)
        % We should have helper utilities for the types which are not objects.
        % Again, we don't care here what happens inside the helper utility, it
        % may add one or more nodes, or just write to attributes.
        
        valNode.setAttribute('type', 'double');
        utils.xml.attachNumberToDom(val, dom, valNode);
      elseif ischar(val)
        valNode.setAttribute('type', 'char');
        utils.xml.attachCharToDom(val, dom, valNode);
      elseif iscellstr(val)
        content = dom.createTextNode(utils.xml.cellstr2str(val));
        valNode.setAttribute('type', 'cellstr');
        valNode.appendChild(content);
      elseif iscell(val)
        valNode.setAttribute('type', 'cell');
        collectedHist = utils.xml.attachCellToDom(val, dom, valNode, collectedHist);
      elseif isstruct(val)
        valNode.setAttribute('type', 'struct');
        collectedHist = utils.xml.attachStructToDom(val, dom, valNode, collectedHist);
      elseif isa(val, 'sym')
        valNode.setAttribute('type', 'sym');
        utils.xml.attachSymToDom(val, dom, valNode);
      elseif isa(val, 'history')
        histUUIDs = val(1).UUID;
        for hh = 2:numel(val)
          histUUIDs = [histUUIDs, ' ', val(hh).UUID];
        end
        valNode.setAttribute('type', 'history');
        valNode.setAttribute('val', histUUIDs);
        collectedHist = val.attachToDom(dom, parent, collectedHist);
      elseif isa(val, 'ltpda_obj')
        valNode.setAttribute('type', class(val));
        collectedHist = val.attachToDom(dom, valNode, collectedHist);
      elseif isa(val, 'sun.util.calendar.ZoneInfo')
        content = dom.createTextNode(char(val.getID));
        valNode.setAttribute('type', class(val));
        valNode.appendChild(content);
      else
        try
          % Part for classes which are NOT implemented in LTPDA. Like LTPDATelemetry.
          valNode.setAttribute('type', class(val));
          collectedHist = val.attachToDom(dom, valNode, collectedHist);
        catch
          error('### Unknown data type to attach [%s].\n\nEach non LTPDA class must implement a public attachToDom(dom, valNode, collectedHist) method and a constructor with two input arguments.\n', class(val));
        end
      end
      paramNode.appendChild(valNode);
      
      % Add desc
      paramNode.setAttribute('desc', obj.desc);
      
      % Add the properties of the paramValue object to the param node
      if isa(obj.val, 'paramValue')
        prop = obj.val.property;
        if ~isempty(prop)
          paramPropertiesNode = dom.createElement('properties');
          collectedHist = utils.xml.attachStructToDom(prop, dom, paramPropertiesNode, collectedHist);
          paramNode.appendChild(paramPropertiesNode);
        end
      end
      
      % Add to parent node
      parent.appendChild(paramNode);
      
    end
  end
  
end
