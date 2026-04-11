
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = ssm.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get amats
    childNode = utils.xml.getChildByName(node, 'amats');
    if ~isempty(childNode)
      obj.amats = utils.xml.getCell(childNode, inhists);
    end
    
    % Get bmats
    childNode = utils.xml.getChildByName(node, 'bmats');
    if ~isempty(childNode)
      obj.bmats = utils.xml.getCell(childNode, inhists);
    end
    
    % Get cmats
    childNode = utils.xml.getChildByName(node, 'cmats');
    if ~isempty(childNode)
      obj.cmats = utils.xml.getCell(childNode, inhists);
    end
    
    % Get dmats
    childNode = utils.xml.getChildByName(node, 'dmats');
    if ~isempty(childNode)
      obj.dmats = utils.xml.getCell(childNode, inhists);
    end
    
    % Get timestep
    childNode = utils.xml.getChildByName(node, 'timestep');
    if ~isempty(childNode)
      obj.timestep = utils.xml.getNumber(childNode);
    end
    
    % Get inputs
    childNode = utils.xml.getChildByName(node, 'inputs');
    if ~isempty(childNode)
      obj.inputs = utils.xml.getObject(childNode, inhists);
    end
    
    % Get states
    childNode = utils.xml.getChildByName(node, 'states');
    if ~isempty(childNode)
      obj.states = utils.xml.getObject(childNode, inhists);
    end
    
    % Get outputs
    childNode = utils.xml.getChildByName(node, 'outputs');
    if ~isempty(childNode)
      obj.outputs = utils.xml.getObject(childNode, inhists);
    end
    
    % Get numparams
    childNode = utils.xml.getChildByName(node, 'numparams');
    if ~isempty(childNode)
      obj.numparams = utils.xml.getObject(childNode, inhists);
    end
    
    % Get params
    childNode = utils.xml.getChildByName(node, 'params');
    if ~isempty(childNode)
      obj.params = utils.xml.getObject(childNode, inhists);
    end
    
  end
  
end
