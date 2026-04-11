
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = mfir.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_filter(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get gd
    childNode = utils.xml.getChildByName(node, 'gd');
    if ~isempty(childNode)
      obj.gd = utils.xml.getNumber(childNode);
    end
    
  end
  
end
