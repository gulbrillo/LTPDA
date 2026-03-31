
function obj = fromDom(obj, node, inhists)
  
  % There exist two possibilities.
  %
  % first (only one unit object):
  %    <plistUsed UUID="..." created="..." creator="..." shape="1x1">
  %       <param key="VALS" shape="1x1" type="double">8</param>
  %    </plistUsed>
  %
  % or (empty plist)
  %    <plistUsed UUID="..." created="..." creator="..." shape="1x1"/>
  %
  % second:
  %    <parent>
  %       <plist UUID="..." created="..."  creator="..." shape="1x1">
  %          <param key="STR" shape="1x4" type="char">text</param>
  %          <param key="NUM" shape="1x1" type="char">123</param>
  %           ...
  %       </plist>
  %    </parent>
  
  nodeName = utils.xml.mchar(node.getNodeName());
  
  if strcmp(nodeName, 'plistUsed') || strcmp(nodeName, 'plist')
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_uo(obj, node, inhists);
    
    %%%%%%%%%% Get properties from the node attributes
    
    %%%%%%%%%% Get properties from the child nodes
    
    p = [];
    
    % Get params
    paramsNodes = utils.xml.getChildrenByName(node, 'param');
    for ii=0:paramsNodes.getLength()-1
      p = [p param(paramsNodes.item(ii), inhists)];
    end
    obj.params = p;
    
  else
    
    %%%%%%%%%% Get plists from child nodes
    obj = utils.xml.getObject(node);
    
  end
  
end
