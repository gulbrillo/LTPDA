
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = specwin.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get type
    childNode = utils.xml.getChildByName(node, 'type');
    if ~isempty(childNode)
      obj.type = utils.xml.getString(childNode);
    end
    
    % Get alpha
    childNode = utils.xml.getChildByName(node, 'alpha');
    if ~isempty(childNode)
      obj.alpha = utils.xml.getNumber(childNode);
    end
    
    % Get psll
    childNode = utils.xml.getChildByName(node, 'psll');
    if ~isempty(childNode)
      obj.psll = utils.xml.getNumber(childNode);
    end
    
    % Get rov
    childNode = utils.xml.getChildByName(node, 'rov');
    if ~isempty(childNode)
      obj.rov = utils.xml.getNumber(childNode);
    end
    
    % Get nenbw
    childNode = utils.xml.getChildByName(node, 'nenbw');
    if ~isempty(childNode)
      obj.nenbw = utils.xml.getNumber(childNode);
    end
    
    % Get w3db
    childNode = utils.xml.getChildByName(node, 'w3db');
    if ~isempty(childNode)
      obj.w3db = utils.xml.getNumber(childNode);
    end
    
    % Get flatness
    childNode = utils.xml.getChildByName(node, 'flatness');
    if ~isempty(childNode)
      obj.flatness = utils.xml.getNumber(childNode);
    end
    
    % Get levelorder
    childNode = utils.xml.getChildByName(node, 'levelorder');
    if ~isempty(childNode)
      obj.levelorder = utils.xml.getNumber(childNode);
    end
    
    % Get skip
    childNode = utils.xml.getChildByName(node, 'skip');
    if ~isempty(childNode)
      obj.skip = utils.xml.getNumber(childNode);
    end
    
    % Get len
    childNode = utils.xml.getChildByName(node, 'len');
    if ~isempty(childNode)
      obj.len = utils.xml.getNumber(childNode);
    end
    
    % Get win
    childNode = utils.xml.getChildByName(node, 'win');
    if ~isempty(childNode)
      obj.len = length(utils.xml.getNumber(childNode));
    end
    
  end
  
end
