
function fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_obj(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  % Get UUID
  obj.UUID = utils.xml.mchar(node.getAttribute('UUID'));
  
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
  
end
