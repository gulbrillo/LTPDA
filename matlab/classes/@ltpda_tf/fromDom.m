
function fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_uoh(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get iunits
  childNode = utils.xml.getChildByName(node, 'iunits');
  if ~isempty(childNode)
    obj.iunits = unit(childNode, inhists);
  end
  
  % Get ounits
  childNode = utils.xml.getChildByName(node, 'ounits');
  if ~isempty(childNode)
    obj.ounits = unit(childNode, inhists);
  end
  
end
