
function values = getVector(node)
  
  shape = utils.xml.getShape(node);
  realValues = [];
  imagValues = [];
  
  for jj = 1:node.getLength()
    
    childNode = node.item(jj-1);
    if childNode.getNodeType == childNode.ELEMENT_NODE
      
      % Get node name
      dataType = utils.xml.mchar(childNode.getNodeName());
      
      if strcmp(dataType, 'realData')
        
        % Get real data
        realValues = getValues(childNode);
        
      elseif strcmp(dataType, 'imagData')
        
        % Get imaginary data
        imagValues = getValues(childNode);
        
      else
        
        error('### Unexpected Node: %s', dataType);
        
      end
      
    end
  end
  
  % Combine the values to complex numbers if necessary
  if ~isempty(imagValues)
    values = complex(realValues, imagValues);
  else
    values = realValues;
  end
  
  % Reshape the values
  values = reshape(values, shape);
  
end

function values = getValues(node)
  
  values = [];
  
  % Collect all vectors
  for nn = 1:node.getLength()
    vectorNode = node.item(nn-1);
    if vectorNode.getNodeType == vectorNode.ELEMENT_NODE
      
      values = [values sscanf(utils.xml.mchar(vectorNode.getTextContent()), '%g ', [1,inf])];
      type = utils.xml.getType(vectorNode);
      
    end
  end
  
  % cast to other number type (if necessary)
  values = cast(values, type);
  
end

