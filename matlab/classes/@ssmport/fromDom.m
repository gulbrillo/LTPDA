
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = ssmport.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get name
    childNode = utils.xml.getChildByName(node, 'name');
    if ~isempty(childNode)
      obj.name = utils.xml.getString(childNode);
    end
    
    % Get units
    childNode = utils.xml.getChildByName(node, 'units');
    if ~isempty(childNode)
      obj.units = unit(childNode, inhists);
    end
    
    % Get description
    childNode = utils.xml.getChildByName(node, 'description');
    if ~isempty(childNode)
      obj.description = utils.xml.getString(childNode);
    end
    
  end
  
end

