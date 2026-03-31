% TOHTML convert an minfo object to an html document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOHTML convert an minfo object to an html document
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tohtml(varargin)
  
  % Get minfo objects
  objs = utils.helper.collect_objects(varargin(:), 'minfo');
  
  if numel(objs) > 1
    error('### Only works for one info object');
  end
  
  txts = html(objs(1));
  
  % display the objects
  if nargout > 0
    varargout{1} = txts;
  elseif nargout == 0;
    helpPath = utils.helper.getHelpPath();
    docStyleFile      = strcat('file://', helpPath, '/ug/docstyle.css');
    
    html = 'text://';
    
    % First the header table
    html = [html sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
    html = [html sprintf('   "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n\n')];
    
    html = [html sprintf('<html lang="en">\n')];
    
    % Header definition
    html = [html sprintf('  <head>\n')];
    html = [html sprintf('    <title>Method Info Report: %s/%s</title>\n', objs.mclass, objs.mname)];
    html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
    html = [html sprintf('  </head>\n\n')];
    
    html = [html sprintf('  <body>\n\n')];
    
    html = [html txts]; % table
    
    html = [html sprintf('  </body>\n')];
    html = [html sprintf('</html>')];
    web(html);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = html(mi)
  
  helpPath = utils.helper.getHelpPath();
  if ispc()
    helpPath = strcat('/', strrep(helpPath, '\', '/'));
  end
  docStyleFile      = ['file://' helpPath '/ug/docstyle.css'];
  prefArrowFile     = ['file://' helpPath '/ug/b_prev.gif'];
  nextArrowFile     = ['file://' helpPath '/ug/b_next.gif'];
  toTopFile         = ['file://' helpPath '/'];
  mainClassDescFile = ['file://' helpPath '/ug/class_desc_main.html'];
  helptocFile       = ['file://' helpPath '/helptoc.html'];
  classDescFile     = ['file://' helpPath '/ug/class_desc_', mi.mclass, '.html'];
  
  txt = '';
  
  % First the header table
  txt = [txt sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
  txt = [txt sprintf('   "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n\n')];
  
  txt = [txt sprintf('<html lang="en">\n')];
  
  % Head definition
  txt = [txt sprintf('  <head>\n')];
  txt = [txt sprintf('    <title>Method Report for %s.%s</title>\n', mi.mclass, mi.mname)];
  txt = [txt sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
  txt = [txt sprintf('  </head>\n\n')];
  
  txt = [txt sprintf('  <body>\n\n')];
  
  txt = [txt sprintf('    <a name="top_of_page" id="top_of_page"></a>\n')];
  txt = [txt sprintf('    <p style="font-size:1px;">&nbsp;</p>\n\n')];
  
  % Table of the navigation (top)
  txt = [txt sprintf('    <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n')];
  txt = [txt sprintf('      <tr>\n')];
  txt = [txt sprintf('        <td valign="baseline"><b>LTPDA Toolbox</b></td>\n')];
  txt = [txt sprintf('        <td><a href="%s">contents</a></td>\n', helptocFile)];
  txt = [txt sprintf('        <td valign="baseline" align="right"><a href=\n')];
  txt = [txt sprintf('            "%s"><img src=\n', mainClassDescFile)];
  txt = [txt sprintf('            "%s" border="0" align="bottom" alt="Class descriptions"></img></a>&nbsp;&nbsp;&nbsp;<a href=\n', prefArrowFile)];
  txt = [txt sprintf('            "%s"><img src=\n', classDescFile)];
  txt = [txt sprintf('            "%s" border="0" align="bottom" alt="%s Class"></a></td>\n', nextArrowFile, upper(mi.mclass))];
  txt = [txt sprintf('      </tr>\n')];
  txt = [txt sprintf('    </table>\n\n')];
  
  txt = [txt sprintf('    <h1 class="title">Method Report for %s.%s</h1>\n', mi.mclass, mi.mname)];
  txt = [txt sprintf('    <hr>\n\n')];
  
  % Documentation
  txt = [txt sprintf('<h2>Description</h2>\n')];
  txt = [txt sprintf('<p>%s</p>', mi.description)];

  txt = [txt mi.tohtmlTable(toTopFile)];
  
%   % Link-Table of the sets
%   txt = [txt sprintf('    <p><!-- Link-Table of the sets -->\n')];
%   txt = [txt sprintf('      <table border="0" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
%   txt = [txt sprintf('        <tr><th>Sets for this method &#8230;</th></tr>\n')];
%   for ll=1:numel(mi.sets)
%     set = mi.sets{ll};
%     txt = [txt sprintf('        	<tr><td><a href="#%d">%s</a></td></tr>\n', ll, set)];
%   end
%   txt = [txt sprintf('      </table>\n')];
%   txt = [txt sprintf('    <p>\n\n')];
%   
%   % Table of the sets
%   for ll=1:numel(mi.sets)
%     set = mi.sets{ll};
%     pl  = mi.plists(ll);
%     pl.setName(set);
%     txt = [txt pl.tohtml(num2str(ll))];
%     
%     % Back to top
%     txt = [txt sprintf('      <!-- ===== Back to top ===== -->\n')];
%     txt = [txt sprintf('      <a href="#top_of_page">\n')];
%     txt = [txt sprintf('        <img src="%s" border="0" align="bottom" alt="back to top"/>\n', toTopFile)];
%     txt = [txt sprintf('        back to top\n')];
%     txt = [txt sprintf('      </a>\n')];
%     txt = [txt sprintf('    </p>\n\n')];
%   end
%   
%   % Table of the minfo object
%   txt = [txt sprintf('    <p><!-- Table of the minfo object -->\n')];
%   txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="2" border="0" width="60%%">\n')];
%   txt = [txt sprintf('        <colgroup>\n')];
%   txt = [txt sprintf('          <col width="25%%"/>\n')];
%   txt = [txt sprintf('          <col width="75%%"/>\n')];
%   txt = [txt sprintf('        </colgroup>\n')];
%   txt = [txt sprintf('        <thead>\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <th class="categorylist" colspan="2">Some information of the method %s/%s are listed below:</th>\n', mi.mclass, mi.mname)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('        </thead>\n')];
%   txt = [txt sprintf('        <tbody>\n')];
%   txt = [txt sprintf('          <!-- Property: ''mclass'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">Class name</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">%s</td>\n', mi.mclass)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''mname'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">Method name</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">%s</td>\n', mi.mname)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''mcategory'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">Category</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">%s</td>\n', mi.mcategory)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''mversion'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">CVS Version</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">%s</td>\n', mi.mversion)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''argsmin'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">Min input args</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">%d</td>\n', mi.argsmin)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''argsmax'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">Max input args</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">%d</td>\n', mi.argsmax)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''outmin'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">Min output args</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#f3f4f5">%d</td>\n', mi.outmin)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('          <!-- Property: ''outmax'' -->\n')];
%   txt = [txt sprintf('          <tr valign="top">\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">Max output args</td>\n')];
%   txt = [txt sprintf('            <td bgcolor="#ffffff">%d</td>\n', mi.outmax)];
%   txt = [txt sprintf('          </tr>\n')];
%   txt = [txt sprintf('        </tbody>\n')];
%   txt = [txt sprintf('      </table>\n')];
%   txt = [txt sprintf('    </p>\n\n')];
  
  % Table of the navigation (bottom)
  txt = [txt sprintf('  <br>\n')];
  txt = [txt sprintf('  <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n')];
  txt = [txt sprintf('    <tr valign="top">\n')];
  txt = [txt sprintf('      <td align="left" width="20">\n')];
  txt = [txt sprintf('        <a href="%s"><img src="%s" border="0" align="bottom" alt="Class descriptions"></img></a>\n', mainClassDescFile, prefArrowFile)];
  txt = [txt sprintf('      </td>\n')];
  txt = [txt sprintf('      <td align="left">Class descriptions</td>\n')];
  txt = [txt sprintf('      <td>&nbsp;</td>\n')];
  txt = [txt sprintf('      <td align="right">%s Class</td>\n', upper(mi.mclass))];
  txt = [txt sprintf('      <td align="right" width="20">\n')];
  txt = [txt sprintf('        <a href="%s"><img src="%s" border="0" align="bottom" alt="%s Class"></img></a>\n', classDescFile, nextArrowFile, upper(mi.mclass))];
  txt = [txt sprintf('      </td>\n')];
  txt = [txt sprintf('    </tr>\n')];
  txt = [txt sprintf('  </table><br>\n')];
  
  txt = [txt sprintf('  <p class="copy">&copy;LTP Team</p>\n')];
  
  txt = [txt sprintf('  </body>\n')];
  txt = [txt sprintf('</html>')];
  
end

