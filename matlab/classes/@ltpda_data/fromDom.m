
function fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_nuo(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get yaxis
  childNode = utils.xml.getChildByName(node, 'yaxis');
  if isempty(childNode)
    
    % load old style of ltpda_data
    % Get yunits
    childNode = utils.xml.getChildByName(node, 'yunits');
    if ~isempty(childNode)
      yunits = unit(childNode, inhists);
    end
    
    % Get y
    childNode = utils.xml.getChildByName(node, 'y');
    if ~isempty(childNode)
      y = utils.xml.getNumber(childNode);
    end
    
    % Get dy
    childNode = utils.xml.getChildByName(node, 'dy');
    if ~isempty(childNode)
      dy = utils.xml.getNumber(childNode);
    end

    obj.yaxis = ltpda_vector(y, dy, yunits);
        
  else
    obj.yaxis = ltpda_vector(childNode, inhists);
  end
  
  
end
