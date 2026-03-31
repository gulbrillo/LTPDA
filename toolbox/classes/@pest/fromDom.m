
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = pest.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get dy
    childNode = utils.xml.getChildByName(node, 'dy');
    if ~isempty(childNode)
      obj.dy = utils.xml.getNumber(childNode);
    end
    
    % Get y
    childNode = utils.xml.getChildByName(node, 'y');
    if ~isempty(childNode)
      obj.y = utils.xml.getNumber(childNode);
    end
    
    % Get names
    childNode = utils.xml.getChildByName(node, 'names');
    if ~isempty(childNode)
      obj.names = eval(utils.xml.mchar(childNode.getTextContent()));
    end
    
    % Get yunits
    childNode = utils.xml.getChildByName(node, 'yunits');
    if ~isempty(childNode)
      obj.yunits = utils.xml.getObject(childNode, inhists);
    end
    
    % Get pdf
    childNode = utils.xml.getChildByName(node, 'pdf');
    if ~isempty(childNode)
      obj.pdf = utils.xml.getNumber(childNode);
    end
    
    % Get cov
    childNode = utils.xml.getChildByName(node, 'cov');
    if ~isempty(childNode)
      obj.cov = utils.xml.getNumber(childNode);
    end
    
    % Get corr
    childNode = utils.xml.getChildByName(node, 'corr');
    if ~isempty(childNode)
      obj.corr = utils.xml.getNumber(childNode);
    end
    
    % Get chi2
    childNode = utils.xml.getChildByName(node, 'chi2');
    if ~isempty(childNode)
      obj.chi2 = utils.xml.getNumber(childNode);
    end
    
    % Get dof
    childNode = utils.xml.getChildByName(node, 'dof');
    if ~isempty(childNode)
      obj.dof = utils.xml.getNumber(childNode);
    end
    
    % Get chain
    childNode = utils.xml.getChildByName(node, 'chain');
    if ~isempty(childNode)
      obj.chain = utils.xml.getNumber(childNode);
    end
    
    % Get models
    childNode = utils.xml.getChildByName(node, 'models');
    if ~isempty(childNode)
      obj.models = utils.xml.getObject(childNode, inhists);
    end
    
  end
  
end
