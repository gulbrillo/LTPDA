
function obj = fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_data(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get xaxis
  childNode = utils.xml.getChildByName(node, 'xaxis');
  if isempty(childNode)
    
    % load old style data2D stuff
    % Get xunits
    childNode = utils.xml.getChildByName(node, 'xunits');
    if ~isempty(childNode)
      xunits = unit(childNode, inhists);
    end
    
    % Get x
    childNode = utils.xml.getChildByName(node, 'x');
    if ~isempty(childNode)
      x = utils.xml.getNumber(childNode);
    end
    
    % Get dx
    childNode = utils.xml.getChildByName(node, 'dx');
    if ~isempty(childNode)
      dx = utils.xml.getNumber(childNode);
    end
    
    obj.xaxis = ltpda_vector(x, dx, xunits);
    
  else
    obj.xaxis = ltpda_vector(childNode, inhists);
  end
  
end
