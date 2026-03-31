
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  type     = utils.xml.mchar(node.getAttribute('type'));
  
  if any(objShape==0) && isempty(type)
    
    obj = plotinfo.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get style
    childNode = utils.xml.getChildByName(node, 'Style');
    if ~isempty(childNode)
      
      obj.style = mpipeline.ltpdapreferences.PlotStyle(childNode);
      
    end
            
    % Get includeInLegend
    obj.includeInLegend = str2double(utils.xml.mchar(node.getAttribute('includeInLegend')));
    
    % Get showErrors
    obj.showErrors = str2double(utils.xml.mchar(node.getAttribute('showErrors')));
    
  end
  
end
