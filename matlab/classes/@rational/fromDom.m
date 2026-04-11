
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = rational.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_tf(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get num
    childNode = utils.xml.getChildByName(node, 'num');
    if ~isempty(childNode)
      obj.num = utils.xml.getNumber(childNode);
    end
    
    % Get den
    childNode = utils.xml.getChildByName(node, 'den');
    if ~isempty(childNode)
      obj.den = utils.xml.getNumber(childNode);
    end
    
  end
  
end
