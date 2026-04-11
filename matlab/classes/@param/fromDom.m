
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  type     = utils.xml.mchar(node.getAttribute('type'));
  
  if any(objShape==0) && isempty(type)
    
    obj = param.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    % Get key
    keyStr = utils.xml.mchar(node.getAttribute('key'));
    if (keyStr(1) == '''' && keyStr(end) == '''') || ...
      (keyStr(1) == '{' && keyStr(end) == '}')
      % We store with the introduction of the alternative key names even a
      % single key name in quotes. So that the command eval() can evaluate
      % a cell-string or a string (wrapped in quotes) into the value of the
      % property 'key'.
      % But this is not possible where we haven't stored the string with
      % quotes.
      obj.key = eval(keyStr);
    else
      obj.key = keyStr;
    end
    
    % get origin
    obj.origin = utils.xml.mchar(node.getAttribute('origin'));
    
    % Get desc
    obj.desc = utils.xml.mchar(node.getAttribute('desc'));
    
    % Get value
    if node.hasAttribute('type')
      % till LTPDA version 2.3.1
      obj.setVal(utils.xml.getFromType(node, inhists));
    else
      
      %%%%%%%%%% Get properties from the child nodes
      % since LTPDA version 2.3.2
      
      % Get val
      childNode = utils.xml.getChildByName(node, 'val');
      if ~isempty(childNode)
        obj.setVal(utils.xml.getFromType(childNode, inhists));
      end
      
      % Get properties
      childNode = utils.xml.getChildByName(node, 'properties');
      if ~isempty(childNode)
        prop = utils.xml.getStruct(childNode, inhists);
        fn = fieldnames(prop);
        for pp = 1:numel(fn)
          obj.setProperty(fn{pp}, prop.(fn{pp}));
        end
      end
    end
    
  end
  
end
