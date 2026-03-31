
function objs = getStruct(node, inhists)
  
  % Get shape
  objShape = sscanf(utils.xml.mchar(node.getAttribute('structShape')), '%dx%d')';
  
  if any(objShape==0)
    
    objs = struct([]);
    objs = reshape(objs, objShape);
    
  else
    
    objs = [];
    % Loop over all structure nodes
    for jj = 1:node.getLength()
      
      structNode = node.item(jj-1);
      if structNode.getNodeType == structNode.ELEMENT_NODE
        
        obj = struct();
        
        % Loop over all fieldnames
        for ff = 1:structNode.getLength()
        
          fieldnameNode = structNode.item(ff-1);
          if fieldnameNode.getNodeType == fieldnameNode.ELEMENT_NODE
            
            fname = utils.xml.mchar(fieldnameNode.getNodeName());
            obj.(fname) = utils.xml.getFromType(fieldnameNode, inhists);
            
          end 
        
        end
        objs = [objs obj];
        
      end
    end
    
    objs = reshape(objs, objShape);
    
  end
  
end


