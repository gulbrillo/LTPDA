% TOHTML creates and HTML table of the input objects
% objects.
% 
% CALL:
%           toHTML(items) % shows in browser
%           toHTML(items, title) % shows in browser
%     txt = toHTML(items)
%     txt = toHTML(items, title)
%
%
%         colNames - a cell-array of the column names for the table
%        headerRow - an HTML table row snippet for an (optional) header
%                    row. If this is empty, the colNames will be used to
%                    generate a header row.
%     tableRowFunc - a function handle that returns an html snippet for a
%                    table row for the given input object. The function
%                    will be passed an object, and the index of the object.
% 
function varargout = toHTML(ps, colNames, headerRow, tableRowFunc)
  
  txt = '';
    
  txt = [txt sprintf('    <!-- Telemetry List Table -->\n')];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  txt = [txt sprintf('        <colgroup>\n')];
  txt = [txt sprintf('          <col />\n')];
  txt = [txt sprintf('          <col />\n')];
  txt = [txt sprintf('          <col />\n')];
  txt = [txt sprintf('          <col />\n')];
  txt = [txt sprintf('          <col />\n')];
  txt = [txt sprintf('        </colgroup>\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  if ~isempty(headerRow)
    txt = [txt headerRow];
  else
    txt = [txt sprintf('        	<tr valign="top">\n')];
    for jj=1:numel(colNames)
      txt = [txt sprintf('        		<th bgcolor="#D7D7D7">%s</th>\n', colNames{jj})];
    end
    txt = [txt sprintf('        	</tr>\n')];
  end
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
  for kk=1:numel(ps)
    p = ps(kk);    
    txt = [txt tableRowFunc(p, kk)];    
  end
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  txt = [txt sprintf('    </p>\n')];
  
  if nargout == 1
    varargout{1} = txt;
  else
    
    helpPath = utils.helper.getHelpPath();
    docStyleFile      = strcat('file://', helpPath, '/ug/docstyle.css');
    
    html = 'text://';
    
    % First the header table
    html = [html sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
    html = [html sprintf('   "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n\n')];
    
    html = [html sprintf('<html lang="en">\n')];
    
    % Header definition
    html = [html sprintf('  <head>\n')];
    html = [html sprintf('    <title>Parameter Report</title>\n')];
    html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
    html = [html sprintf('  </head>\n\n')];
    
    html = [html sprintf('  <body>\n\n')];
    
    html = [html txt]; % table
    
    html = [html sprintf('  </body>\n')];
    html = [html sprintf('</html>')];
    web(html);
    
  end
  
  
end
