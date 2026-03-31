
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = filterbank.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get filters
    childNode = utils.xml.getChildByName(node, 'filters');
    if ~isempty(childNode)
      obj.filters = utils.xml.getObject(childNode, inhists);
    end
    
    % Get type
    childNode = utils.xml.getChildByName(node, 'type');
    if ~isempty(childNode)
      obj.type = utils.xml.getString(childNode);
    end
    
  end
  
end
