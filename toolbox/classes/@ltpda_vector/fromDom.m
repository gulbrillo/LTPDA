
function obj = fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_nuo(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  % name
  obj.name = utils.xml.mchar(node.getAttribute('name'));
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get data
  childNode = utils.xml.getChildByName(node, 'data');
  if ~isempty(childNode)
    obj.data = utils.xml.getNumber(childNode);
  end
  
  % Get ddata
  childNode = utils.xml.getChildByName(node, 'ddata');
  if ~isempty(childNode)
    obj.ddata = utils.xml.getNumber(childNode);
  end
  
  % Get units
  childNode = utils.xml.getChildByName(node, 'units');
  if ~isempty(childNode)
    obj.units = utils.xml.getObject(childNode, inhists);
  end
  
end
