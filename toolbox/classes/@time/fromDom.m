
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = time.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get utc_epoch_milli
    obj.utc_epoch_milli = str2double(utils.xml.mchar(node.getAttribute('utc_epoch_milli')));
    
    %%%%%%%%%% Get properties from the child nodes
    
  end
  
end
