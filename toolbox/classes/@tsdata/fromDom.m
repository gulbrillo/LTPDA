
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = tsdata.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@data2D(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get t0
    childNode = utils.xml.getChildByName(node, 't0');
    if ~isempty(childNode)

      t0 = utils.xml.getObject(childNode, inhists);
      
      % We keep the meaning of t0 for backwars compatibility. This means
      % - before saving, t0 = t0 + toffset
      % - after loading, t0 = t0 - toffset
      offsetNode = utils.xml.getChildByName(node, 'toffset');
      if ~isempty(offsetNode)
        offset = utils.xml.getNumber(offsetNode);
        t0 = t0 - offset/1e3;
      end
      
      obj.t0 = t0;
    end
    
    % Get toffset
    childNode = utils.xml.getChildByName(node, 'toffset');
    if ~isempty(childNode)
      obj.toffset = utils.xml.getNumber(childNode);
    end
    
    % Get fs
    childNode = utils.xml.getChildByName(node, 'fs');
    if ~isempty(childNode)
      obj.fs = utils.xml.getNumber(childNode);
    end
    
    % Get nsecs
    childNode = utils.xml.getChildByName(node, 'nsecs');
    if ~isempty(childNode)
      obj.nsecs = utils.xml.getNumber(childNode);
    end
    
  end
  
end

