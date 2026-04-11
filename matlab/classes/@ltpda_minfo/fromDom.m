
function obj = fromDom(obj, node, inhists)
  
  % there exist some possibilities.
  %
  % first (only one ltpda_minfo-object with no children):
  %    <parent methodInfo="#abs#ao#operator#(id):..."/>
  %
  % second (more than one ltpda_minfo with no children)
  %    <parent>
  %       <ltpda_minfo shape="1x2" methodInfo="#abs#ao#operator#(id):..."/>
  %       <ltpda_minfo shape="1x2" methodInfo="#sin#ao#operator#(id):..."/>
  %    </parent>
  %
  % third
  %    <parent>
  %       <ltpda_minfo shape="1x1" methodInfo="#abs#ao#operator#(id):...">
  %          <ltpda_minfo shape="1x2" methodInfo="#child11#ao#operator#(id):..."/>
  %          <ltpda_minfo shape="1x2" methodInfo="#child12#ao#operator#(id):..."/>
  %       </ltpda_minfo>
  %    </parent>
  %
  
  if node.hasAttribute('methodInfo')
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);

    % get encoded string
    info = utils.xml.mchar(node.getAttribute('methodInfo'));
    
    obj = ltpda_minfo.setFromEncodedInfo(obj, info);
    
    % check if there are some children if the node name is 'minfo' (XML tag kept
    % as 'minfo' for backward compat with existing saved files)
    nodeName = utils.xml.mchar(node.getNodeName);
    if strcmp(nodeName, 'minfo')
      obj.children = utils.xml.getObject(node, inhists);
    end
    
  else
    
    % get shape
    objshape = utils.xml.getShape(node);
    
    if any(objshape==0)
      
      obj = ltpda_minfo.initObjectWithSize(objshape(1), objshape(2));
      
    else
      
      %%%%%%%%%% get ltpda_minfo objects from child nodes
      obj = utils.xml.getObject(node, inhists);
    end
    
  end
end

