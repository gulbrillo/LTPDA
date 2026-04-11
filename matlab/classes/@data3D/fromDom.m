
function obj = fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@data2D(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get zaxis
  childNode = utils.xml.getChildByName(node, 'zaxis');
  if isempty(childNode)
    
    % load old style zaxis stuff
    % Get zunits
    childNode = utils.xml.getChildByName(node, 'zunits');
    if ~isempty(childNode)
      zunits = unit(childNode, inhists);
    end
    
    % Get z
    childNode = utils.xml.getChildByName(node, 'z');
    if ~isempty(childNode)
      z = utils.xml.getNumber(childNode);
    end
    
    % Get dz
    childNode = utils.xml.getChildByName(node, 'dz');
    if ~isempty(childNode)
      dz = utils.xml.getNumber(childNode);
    end
    
    obj.zaxis = ltpda_vector(z, dz, zunits);
    
  else
    obj.zaxis = ltpda_vector(childNode, inhists);
  end

  
end
