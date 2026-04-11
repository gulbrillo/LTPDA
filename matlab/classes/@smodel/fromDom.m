
function obj = fromDom(obj, node, inhists)
  
  % Get shape
  objShape = utils.xml.getShape(node);
  
  if any(objShape==0)
    
    obj = smodel.initObjectWithSize(objShape(1), objShape(2));
    
  else
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uoh(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    % Get expr
    childNode = utils.xml.getChildByName(node, 'expr');
    if ~isempty(childNode)
      obj.expr = utils.xml.getString(childNode);
    end
    
    % Get params
    childNode = utils.xml.getChildByName(node, 'params');
    if ~isempty(childNode)
      obj.params = eval(utils.xml.mchar(childNode.getTextContent()));
    end
    
    % Get values
    childNode = utils.xml.getChildByName(node, 'values');
    if ~isempty(childNode)
      obj.values = utils.xml.getCell(childNode, inhists);
    end
    
    % Get trans
    childNode = utils.xml.getChildByName(node, 'trans');
    if ~isempty(childNode)
      type = utils.xml.mchar(childNode.getAttribute('type'));
      if strcmp(type, 'char')
        obj.trans = utils.xml.getString(childNode);
      elseif strcmp(type, 'cell')
        obj.trans = utils.xml.getCell(childNode, inhists);
      else
        error('### Don''t expect the type %s for ''xvals''', type);
      end
    end
    
    % Get xvar
    childNode = utils.xml.getChildByName(node, 'xvar');
    if ~isempty(childNode)
      type = utils.xml.mchar(childNode.getAttribute('type'));
      if strcmp(type, 'char')
        obj.xvar = utils.xml.getString(childNode);
      elseif strcmp(type, 'cellstr')
        obj.xvar = eval(utils.xml.mchar(childNode.getTextContent()));
      else
        error('### Don''t expect the type %s for ''xvals''', type);
      end
    end
    
    % Get xvals
    childNode = utils.xml.getChildByName(node, 'xvals');
    if ~isempty(childNode)
      type = utils.xml.mchar(childNode.getAttribute('type'));
      if strcmp(type, 'cell')
        obj.xvals = utils.xml.getCell(childNode, inhists);
      elseif strcmp(type, 'double')
        obj.xvals = utils.xml.getNumber(childNode);
      else
        error('### Don''t expect the type %s for ''xvals''', type);
      end
    end
    
    % Get xunits
    childNode = utils.xml.getChildByName(node, 'xunits');
    if ~isempty(childNode)
      obj.xunits = unit(childNode, inhists);
    end
    
    % Get yunits
    childNode = utils.xml.getChildByName(node, 'yunits');
    if ~isempty(childNode)
      obj.yunits = unit(childNode, inhists);
    end
    
    % Get aliasNames
    childNode = utils.xml.getChildByName(node, 'aliasNames');
    if ~isempty(childNode)
      obj.aliasNames = utils.xml.getCell(childNode, inhists);
    end
    
    % Get aliasValues
    childNode = utils.xml.getChildByName(node, 'aliasValues');
    if ~isempty(childNode)
      obj.aliasValues = utils.xml.getCell(childNode, inhists);
    end
    
  end
  
end
