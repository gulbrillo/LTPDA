
function obj = getCellstr(node)
  
  % Get the shape from the attribute
  shape = utils.xml.getShape(node);
  
  if any(shape == 0)
    % Create empty cell object.
    obj = cell(shape);
  else
    % Get node content and convert it back to a cell of strings
    obj = eval(node.getTextContent());
    
    % Reshape cell object to the right shape
    obj = reshape(obj, shape);
  end
  
end

