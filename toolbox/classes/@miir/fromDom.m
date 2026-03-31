
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = miir.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_filter(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get b
    childNode = utils.xml.getChildByName(node, 'b');
    if ~isempty(childNode)
      obj.b = utils.xml.getNumber(childNode);
    end
    
    % Get histin
    childNode = utils.xml.getChildByName(node, 'histin');
    if ~isempty(childNode)
      obj.histin = utils.xml.getNumber(childNode);
    end
    
  end
  
end
