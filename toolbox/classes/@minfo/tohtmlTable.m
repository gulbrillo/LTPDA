% TOHTMLTABLE convert an minfo object to a html table without <HTML>, <BODY>, ... tags
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOHTMLTABLE convert an minfo object to a html table without
%              <HTML>, <BODY>, ... tags
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tohtmlTable(obj, relPathToHelp)
  
  % Check input
  if numel(obj) > 1
    error('### Only works for one info object');
  end
  
  toTopFile = strcat(relPathToHelp, 'ug/doc_to_top_up.gif');
  
  html = sprintf('\n');
  
  % Link-Table of the sets
  html = sprintf('%s    <!-- Link-Table of the sets -->\n', html);
  html = sprintf('%s    <table border="0" cellpadding="4" cellspacing="0" class="pagenavtable">\n', html);
  html = sprintf('%s      <tr><th>Sets for this method &#8230;</th></tr>\n', html);
  for ll=1:numel(obj.sets)
    set = obj.sets{ll};
    html = sprintf('%s        <tr><td><a href="#%d">%s</a></td></tr>\n', html, ll, set);
  end
  html = sprintf('%s    </table>\n', html);
  html = sprintf('%s\n', html);
  
  % Table of the sets
  for ll=1:numel(obj.sets)
    set = obj.sets{ll};
    pl  = obj.plists(ll);
    pl.setName(set);
    html = sprintf('%s%s', html, pl.tohtml(num2str(ll)));
    
    % Back to top
    html = [html sprintf('      <!-- ===== Back to top ===== -->\n')];
    html = [html sprintf('      <a href="#top_of_page">\n')];
    html = [html sprintf('        <img src="%s" border="0" align="bottom" alt="back to top"/>\n', toTopFile)];
    html = [html sprintf('        back to top\n')];
    html = [html sprintf('      </a>\n')];
    html = [html sprintf('    </p>\n\n')];
  end
  
  % Table of the minfo object
  html = [html sprintf('    <p><!-- Table of the minfo object -->\n')];
  html = [html sprintf('      <table cellspacing="0" class="body" cellpadding="2" border="0" width="60%%">\n')];
  html = [html sprintf('        <colgroup>\n')];
  html = [html sprintf('          <col width="25%%"/>\n')];
  html = [html sprintf('          <col width="75%%"/>\n')];
  html = [html sprintf('        </colgroup>\n')];
  html = [html sprintf('        <thead>\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <th class="categorylist" colspan="2">Some information of the method %s/%s are listed below:</th>\n', obj.mclass, obj.mname)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('        </thead>\n')];
  html = [html sprintf('        <tbody>\n')];
  html = [html sprintf('          <!-- Property: ''mclass'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">Class name</td>\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">%s</td>\n', obj.mclass)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('          <!-- Property: ''mname'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">Method name</td>\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">%s</td>\n', obj.mname)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('          <!-- Property: ''mcategory'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">Category</td>\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">%s</td>\n', obj.mcategory)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('          <!-- Property: ''mpackage'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">Package name</td>\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">%s</td>\n', obj.mpackage)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('          <!-- Property: ''modifier'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">Can be used as modifier</td>\n')];
  html = [html sprintf('            <td bgcolor="#f3f4f5">%d</td>\n', obj.modifier)];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('          <!-- Property: ''supportedNumTypes'' -->\n')];
  html = [html sprintf('          <tr valign="top">\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">Supported numeric types</td>\n')];
  html = [html sprintf('            <td bgcolor="#ffffff">%s</td>\n', utils.helper.val2str(obj.supportedNumTypes))];
  html = [html sprintf('          </tr>\n')];
  html = [html sprintf('        </tbody>\n')];
  html = [html sprintf('      </table>\n')];
  html = [html sprintf('    </p>\n\n')];
  
  % display the objects
  if nargout > 0
    varargout{1} = html;
  elseif nargout == 0;
    disp(html);
  end
end

