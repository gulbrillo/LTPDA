
function values = getNumber(node)
  
  shape = utils.xml.getShape(node);
  type  = utils.xml.getType(node);
  
  if any(shape==0)
    
    % Special case for an empty double.
    values = zeros(shape);
    
  else
    
    if  strcmp(type, 'double') || strncmp(type, 'uint', 4) || strncmp(type, 'int', 3) || ...
        strcmp(type, 'single') || strcmp(type, 'float') || strcmp(type, 'logical')
      
      % Get the values direct from the node content
      numberStr = utils.xml.mchar(node.getTextContent());
      if ~isempty(strfind(numberStr, '['))
        values = eval(numberStr);
      else
        values = sscanf(numberStr, '%g ');
      end
      
      % Cast to correct type
      if ~strcmp(type, 'double')
        values = cast(values, type);
      end
      
    elseif strcmp(type, 'doubleVector')
      
      % Get vector
      values = utils.xml.getVector(node);
      
    elseif strcmp(type, 'doubleMatrix')
      
      % Get matrix
      values = utils.xml.getMatrix(node);
      
    else
      
      error('### Unknown number type [%s]', type);
      
    end
    
    % Reshape the values
    values = reshape(values, shape);
    
  end
  
end
