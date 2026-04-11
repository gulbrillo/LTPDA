% TOHTML creates an html representation of the ssmblock
% 
% CALL
%         html = obj.tohtml
% 

function txt = tohtml(varargin)
  
  if nargin ~= 1
    error('ssmblock/toHTML requires a single ssmblock input.');
  end
  
  block = varargin{1};
  
  txt = '';
  txt = [txt sprintf('    <p><!-- SSMPORTS Table for %s -->\n', block.name)];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  txt = [txt sprintf('        <colgroup>\n')];
  txt = [txt sprintf('          <col width="15%%"/>\n')];
  txt = [txt sprintf('          <col width="20%%"/>\n')];
  txt = [txt sprintf('          <col width="15%%"/>\n')];
  txt = [txt sprintf('          <col width="50%%"/>\n')];
  txt = [txt sprintf('        </colgroup>\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="4"><h3><a name="%s">%s</a></h3></th>\n',  utils.helper.genvarname(block.name), block.name)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<td bgcolor="#B9C6DD" colspan="4">%s</td>\n',  block.description)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">#</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Name</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Units</th>\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Description</th>\n')];
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  txt = [txt sprintf('        <tbody>\n')];
  for kk=1:numel(block.ports)
    port = block.ports(kk);
    txt = [txt sprintf('          <tr valign="top">\n')];
    txt = [txt sprintf('            <td bgcolor="#F2F2F2">%d</td>\n', kk)];
    txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', port.name)];
    txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', char(port.units))];
    txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', char(strrep(port.description, '\n', '<br></br>')))];
    txt = [txt sprintf('          </tr>\n')];    
  end
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table></p>\n')];
  
end