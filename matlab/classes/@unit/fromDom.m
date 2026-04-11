
function obj = fromDom(obj, node, inhists)
  
  % There exist two possibilities.
  %
  % first (only one unit object):
  %    <parent exps="1" shape="1x1" strs="{'Hz'}" vals="1"/>
  %
  % second:
  %    <parent>
  %       <unit exps="1" shape="1x2" strs="{'Hz'}" vals="1"/>
  %       <unit exps="1" shape="1x2" strs="{'m'}" vals="1000"/>
  %    </parent>
  
  
  if node.hasAttribute('shape')
    
    %%%% first possibility
    % Get shape
    objShape = utils.xml.getShape(node);
    
    if any(objShape==0)
      
      obj = unit.initObjectWithSize(objShape(1), objShape(2));
      
    else
      
      %%%%%%%%%% Call super-class
      
      fromDom@ltpda_nuo(obj, node, inhists);
      
      %%%%%%%%%% Get properties from the node attributes
      
      % Add strs
      obj.strs = eval(utils.xml.mchar(node.getAttribute('strs')));
      
      % Add exps
      obj.exps = eval(utils.xml.mchar(node.getAttribute('exps')));
      
      % Add vals
      obj.vals = eval(utils.xml.mchar(node.getAttribute('vals')));
      
      % ensure we pass through the parsing routine of the constructor
      % otherwise prefixes etc are not properly handled for some files.
      obj = unit(char(obj));
      
    end
    
  else
    
    %%%% second possibility
    % If the parent don't have the attribute 'shape' then are the unit
    % objects in the child nodes.
    
    %%%%%%%%%% Get units from child nodes
    obj = utils.xml.getObject(node, inhists);
    
  end
  
end
