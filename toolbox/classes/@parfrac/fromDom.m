
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = parfrac.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_tf(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get res
    childNode = utils.xml.getChildByName(node, 'res');
    if ~isempty(childNode)
      obj.res = utils.xml.getNumber(childNode);
    end
    
    % Get poles
    childNode = utils.xml.getChildByName(node, 'poles');
    if ~isempty(childNode)
      obj.poles = utils.xml.getNumber(childNode);
    end
    
    % Get pmul
    childNode = utils.xml.getChildByName(node, 'pmul');
    if ~isempty(childNode)
      obj.pmul = utils.xml.getNumber(childNode);
    end
    
    % Get dir
    childNode = utils.xml.getChildByName(node, 'dir');
    if ~isempty(childNode)
      obj.dir = utils.xml.getNumber(childNode);
    end
    
  end
  
end
