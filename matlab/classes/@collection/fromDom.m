
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = collection.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get objs
    childNode = utils.xml.getChildByName(node, 'objs');
    if ~isempty(childNode)
      obj.objs = utils.xml.getCell(childNode, inhists);
    end
    
    % Get names
    childNode = utils.xml.getChildByName(node, 'names');
    if ~isempty(childNode)
      obj.names = utils.xml.getCell(childNode, inhists);
    end
    
  end
  
end
