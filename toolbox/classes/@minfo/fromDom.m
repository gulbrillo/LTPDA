
function obj = fromDom(obj, node, inhists)
  
  % there exist some possibilities.
  %
  % first (only one minfo-object with no children):
  %    <parent methodInfo="#abs#ao#operator#(id):..."/>
  %
  % second (more than one minfo with no children)
  %    <parent>
  %       <minfo shape="1x2" methodInfo="#abs#ao#operator#(id):..."/>
  %       <minfo shape="1x2" methodInfo="#sin#ao#operator#(id):..."/>
  %    </parent>
  %
  % third
  %    <parent>
  %       <minfo shape="1x1" methodInfo="#abs#ao#operator#(id):...">
  %          <minfo shape="1x2" methodInfo="#child11#ao#operator#(id):..."/>
  %          <minfo shape="1x2" methodInfo="#child12#ao#operator#(id):..."/>
  %       </minfo>
  %    </parent>
  %
  
  if node.hasAttribute('methodInfo')
    
    %%%%%%%%%% Call super-class
    
    fromDom@ltpda_nuo(obj, node, inhists);

    % get encoded string
    info = utils.xml.mchar(node.getAttribute('methodInfo'));
    
    obj = minfo.setFromEncodedInfo(obj, info);
    
    % check if there are some children if the node name is 'minfo'
    nodeName = utils.xml.mchar(node.getNodeName);
    if strcmp(nodeName, 'minfo')
      obj.children = utils.xml.getObject(node, inhists);
    end
    
  else
    
    % get shape
    objshape = utils.xml.getShape(node);
    
    if any(objshape==0)
      
      obj = minfo.initObjectWithSize(objshape(1), objshape(2));
      
    else
      
      %%%%%%%%%% get minfo objects from child nodes
      obj = utils.xml.getObject(node, inhists);
    end
    
  end
end

