
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = matrix.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get objs
    childNode = utils.xml.getChildByName(node, 'objs');
    if ~isempty(childNode)
      obj.objs = utils.xml.getObject(childNode, inhists);
    end
    
  end
  
end
