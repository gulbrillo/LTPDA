
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = mfh.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get objs
    childNode = utils.xml.getChildByName(node, 'objs');
    if ~isempty(childNode)
      obj.objs = utils.xml.getCell(childNode, inhists);
    end
    
    % Get func
    childNode = utils.xml.getChildByName(node, 'func');
    if ~isempty(childNode)
      obj.func = utils.xml.getString(childNode);
    end
    
    % Get funcDef
    childNode = utils.xml.getChildByName(node, 'funcDef');
    if ~isempty(childNode)
      obj.funcDef = utils.xml.getString(childNode);
    end    
    
    % get paramsDef
    childNode = utils.xml.getChildByName(node, 'paramsDef');
    if ~isempty(childNode)
      obj.paramsDef = utils.xml.getObject(childNode, inhists);
    end
    
    % get subfuncs
    childNode = utils.xml.getChildByName(node, 'subfuncs');
    if ~isempty(childNode)
      obj.subfuncs = utils.xml.getObject(childNode, inhists);
    end
    
    % get inputs
    childNode = utils.xml.getChildByName(node, 'inputs');
    if ~isempty(childNode)
      obj.inputs = utils.xml.getCellstr(childNode);
    end
    
    % get input objects
    childNode = utils.xml.getChildByName(node, 'inputObjects');
    if ~isempty(childNode)
      obj.inputObjects = utils.xml.getCell(childNode, inhists);
    end
    
    % get constants
    childNode = utils.xml.getChildByName(node, 'constants');
    if ~isempty(childNode)
      obj.constants = utils.xml.getCell(childNode, inhists);
    end
    
    % get constant objects
    childNode = utils.xml.getChildByName(node, 'constObjects');
    if ~isempty(childNode)
      obj.constObjects = utils.xml.getCell(childNode, inhists);
    end
    
    % get numeric
    childNode = utils.xml.getChildByName(node, 'numeric');
    if ~isempty(childNode)
      obj.numeric = utils.xml.getNumber(childNode);
    end
    
  end
end





