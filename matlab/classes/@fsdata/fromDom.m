
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = fsdata.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@data2D(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get t0
    childNode = utils.xml.getChildByName(node, 't0');
    if ~isempty(childNode)
      obj.t0 = utils.xml.getObject(childNode, inhists);
    end
    
    % Get fs
    childNode = utils.xml.getChildByName(node, 'fs');
    if ~isempty(childNode)
      obj.fs = utils.xml.getNumber(childNode);
    end
    
    % Get navs
    childNode = utils.xml.getChildByName(node, 'navs');
    if ~isempty(childNode)
      obj.navs = utils.xml.getNumber(childNode);
    end
    
    % Get enbw
    childNode = utils.xml.getChildByName(node, 'enbw');
    if ~isempty(childNode)
      obj.enbw = utils.xml.getNumber(childNode);
    end
    
  end
  
end

