
function obj = fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get name
  childNode = utils.xml.getChildByName(node, 'name');
  if ~isempty(childNode)
    obj.name = utils.xml.getString(childNode);
  end
  
  % Get description
  childNode = utils.xml.getChildByName(node, 'description');
  if ~isempty(childNode)
    obj.description = utils.xml.getString(childNode);
  end
    
  % Get units
  childNode = utils.xml.getChildByName(node, 'units');
  if ~isempty(childNode)
    obj.units = utils.xml.getObject(childNode, inhists);
  end
  
end
