
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = pzmodel.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_tf(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get poles
    childNode = utils.xml.getChildByName(node, 'poles');
    if ~isempty(childNode)
      obj.poles = utils.xml.getObject(childNode, inhists);
    end
    
    % Get zeros
    childNode = utils.xml.getChildByName(node, 'zeros');
    if ~isempty(childNode)
      obj.zeros = utils.xml.getObject(childNode, inhists);
    end
    
    % Get gain
    childNode = utils.xml.getChildByName(node, 'gain');
    if ~isempty(childNode)
      obj.gain = utils.xml.getNumber(childNode);
    end
    
    % Get delay
    childNode = utils.xml.getChildByName(node, 'delay');
    if ~isempty(childNode)
      obj.delay = utils.xml.getNumber(childNode);
    end
    
  end
  
end
