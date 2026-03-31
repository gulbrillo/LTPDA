
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = timespan.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get startT
    childNode = utils.xml.getChildByName(node, 'startT');
    if ~isempty(childNode)
      obj.startT = utils.xml.getObject(childNode, inhists);
    end
    
    % Get endT
    childNode = utils.xml.getChildByName(node, 'endT');
    if ~isempty(childNode)
      obj.endT = utils.xml.getObject(childNode, inhists);
    end
    
  end
  
end
