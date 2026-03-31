
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = ao.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Add package
    obj.package = utils.xml.mchar(node.getAttribute('PACKAGE'));
      
    % Add category    
    obj.category = utils.xml.mchar(node.getAttribute('CATEGORY'));
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get params
    childNode = utils.xml.getChildByName(node, 'params');
    if ~isempty(childNode)
      obj.params = utils.xml.getObject(childNode, inhists);
    end
    
    % Get model
    childNode = utils.xml.getChildByName(node, 'model');
    if ~isempty(childNode)
      obj.model = utils.xml.getObject(childNode, inhists);
    end
    
    % Get inputs
    childNode = utils.xml.getChildByName(node, 'inputs');
    if ~isempty(childNode)
      obj.inputs = utils.xml.getObject(childNode, inhists);
    end
    
    % Get outputs
    childNode = utils.xml.getChildByName(node, 'outputs');
    if ~isempty(childNode)
      obj.outputs = utils.xml.getObject(childNode, inhists);
    end
    
    % Get noise
    childNode = utils.xml.getChildByName(node, 'noise');
    if ~isempty(childNode)
      obj.noise = utils.xml.getObject(childNode, inhists);
    end
    
    % Get covariance
    childNode = utils.xml.getChildByName(node, 'covariance');
    if ~isempty(childNode)
      if strcmp(childNode.getAttribute('type'), 'double')
        obj.covariance = utils.xml.getNumber(childNode);
      else
        obj.covariance = utils.xml.getObject(childNode, inhists);
      end
    end
    
    % Get logParams
    childNode = utils.xml.getChildByName(node, 'logParams');
    if ~isempty(childNode)
      obj.logParams = utils.xml.getNumber(childNode);
    end
    
    % Get dstep
    childNode = utils.xml.getChildByName(node, 'diffStep');
    if ~isempty(childNode)
      if strcmp(childNode.getAttribute('type'), 'double')
        obj.diffStep = utils.xml.getNumber(childNode);
      else
        obj.diffStep = utils.xml.getObject(childNode, inhists);
      end
    end
    
    % Get freqs
    childNode = utils.xml.getChildByName(node, 'freqs');
    if ~isempty(childNode)
      obj.freqs = utils.xml.getNumber(childNode);
    end
    
    % Get processed model
    childNode = utils.xml.getChildByName(node, 'processedModel');
    if ~isempty(childNode)
      obj.processedModel = utils.xml.getObject(childNode, inhists);
    end
    
    % Get pest
    childNode = utils.xml.getChildByName(node, 'pest');
    if ~isempty(childNode)
      obj.pest = utils.xml.getObject(childNode, inhists);
    end
    
    % Get llh
    childNode = utils.xml.getChildByName(node, 'loglikelihood');
    if ~isempty(childNode)
      obj.loglikelihood = utils.xml.getObject(childNode, inhists);
    end
    
  end
  
end
