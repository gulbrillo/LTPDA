
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = pz.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get f
    obj.f = eval(utils.xml.mchar(node.getAttribute('f')));
    
    % Get q
    obj.q = eval(utils.xml.mchar(node.getAttribute('q')));
    
    % Get ri
    obj.ri = eval(utils.xml.mchar(node.getAttribute('ri')));
    
    %%%%%%%%%% Get properties from the child nodes
    
  end
  
end

