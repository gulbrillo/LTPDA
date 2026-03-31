
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = ssmblock.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get name
    childNode = utils.xml.getChildByName(node, 'name');
    if ~isempty(childNode)
      obj.name = utils.xml.getString(childNode);
    end
    
    % Get ports
    childNode = utils.xml.getChildByName(node, 'ports');
    if ~isempty(childNode)
      obj.ports = utils.xml.getObject(childNode, inhists);
    end
    
    % Get description
    childNode = utils.xml.getChildByName(node, 'description');
    if ~isempty(childNode)
      obj.description = utils.xml.getString(childNode);
    end
    
  end
  
end
