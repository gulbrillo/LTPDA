
function fromDom(obj, node, inhists)
  
  %%%%%%%%%% Call super-class
  
  fromDom@ltpda_uoh(obj, node, inhists);
  
  %%%%%%%%%% Get properties from the node attributes
  
  %%%%%%%%%% Get properties from the child nodes
  
  % Get fs
  childNode = utils.xml.getChildByName(node, 'fs');
  if ~isempty(childNode)
    obj.fs = utils.xml.getNumber(childNode);
  end
  
  % Get infile
  childNode = utils.xml.getChildByName(node, 'infile');
  if ~isempty(childNode)
    obj.infile = utils.xml.getString(childNode);
  end
  
  % Get a
  childNode = utils.xml.getChildByName(node, 'a');
  if ~isempty(childNode)
    obj.a = utils.xml.getNumber(childNode);
  end
  
  % Get histout
  childNode = utils.xml.getChildByName(node, 'histout');
  if ~isempty(childNode)
    obj.histout = utils.xml.getNumber(childNode);
  end
  
end
