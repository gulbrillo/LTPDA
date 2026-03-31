% Reads each item in the TOC and makes a nested html list.
%
% M Hewitson 24-07-07
%
% $Id$
%
function  read_item(fid, ch)
  
  children = ch.getChildNodes;
  
  % Go through children of AO object
  for j=1:children.getLength
    
    ch = children.item(j-1);
    
    if ch.getNodeType ~= ch.COMMENT_NODE
      
      childs = ch.getChildNodes;
      
      nodeName = char(ch.getNodeName);
      
      txtcon = deblank(char(ch.getTextContent));
      
      if childs.getLength >= 1
        fprintf(fid, '<ul>\n');
        createContentFile.read_item(fid, ch);
        fprintf(fid, '</ul>\n');
      elseif ~isempty(txtcon)
        % check if this node has a target attribute
        p = ch.getParentNode;
        att = p.getAttributes;
        if ~isempty(att)
          target = deblank(char(att.getNamedItem('target')));
          if ~isempty(target)
            fprintf(fid, '<li><a %s>%s</a></li>\n', strrep(target, 'target', 'href'), txtcon);
          else
            fprintf(fid, '<li>%s</li>\n', txtcon);
          end
        else
          fprintf(fid, '<li>%s</li>\n', txtcon);
        end
      else
      end
      
    end
    
  end

end