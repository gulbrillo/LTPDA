
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = provenance.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get encoded string
    info = utils.xml.mchar(node.getAttribute('creator'));
    
    obj = provenance.setFromEncodedInfo(obj, info);
    
    %%%%%%%%%% Get properties from the child nodes
    
  end
  
end

