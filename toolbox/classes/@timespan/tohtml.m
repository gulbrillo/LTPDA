% TOHTML produces an html table from the input timespans.
%
% CALL:
%            ts.tohtml; % table will be shown in document browser
%      txt = ts.tohtml; % stand-alone table for inclusion in html doc
%

function varargout = tohtml(varargin)
  
  % Collect all timespans
  [tss, ts_invars] = utils.helper.collect_objects(varargin(:), 'timespan');
  
  txt = tableHeader();
  
  for kk=1:numel(tss)
  
    ts = tss(kk);
    
    txt = [txt sprintf('          <tr valign="top">\n')];
    txt = [txt sprintf('          <td>%s</td><td>%s</td><td>%s</td><td>%s</td>\n', format(ts.startT), format(ts.endT), ts.name, ts.description)];
    txt = [txt sprintf('          </tr>\n')];
    
  end
  
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  
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
    html = [html sprintf('    <title>Timespan List</title>\n')];
    html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
    html = [html sprintf('  </head>\n\n')];
    
    html = [html sprintf('  <body>\n\n')];
    
    html = [html txt]; % table
    
    html = [html sprintf('  </body>\n')];
    html = [html sprintf('</html>')];
    web(html);
    
  end
  
end

function txt = tableHeader()
  
  txt = '';
  
  txt = [txt sprintf('    <!-- Timespan List Table -->\n')];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Start</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">End</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Name</th>\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Description</th>\n')];
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
  
end

