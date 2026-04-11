% TOHTML produces an html table from the plist.
%
% CALL:
%            pl.tohtml; % table will be shown in document browser
%      txt = pl.tohtml; % stand-alone table for inclusion in html doc
%

function varargout = tohtml(pl, anchor)
  
  txt = '';
  
  name = pl.name;
  if isempty(name)
    name = 'Unknown Plist';
  end
  
  description = pl.description;
  if isempty(description)
    description = '<i>no description</i>';
  end
  
  hasProperties = false;
  colspan       = 4;
  for ii=1:numel(pl.params)
    if ~isempty(pl.params(ii).getProperties())
      hasProperties = true;
      colspan       = 5;
      break
    end
  end
  
  if nargin > 1 && ischar(anchor)
    txt = [txt sprintf('    <a name="%s"></a>\n', anchor)];
  end
  txt = [txt sprintf('    <!-- Parameter List Table: %s -->\n', name)];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  txt = [txt sprintf('        <colgroup>\n')];
  if hasProperties
    txt = [txt sprintf('          <col width="15%%"/>\n')];
    txt = [txt sprintf('          <col width="15%%"/>\n')];
    txt = [txt sprintf('          <col width="15%%"/>\n')];
    txt = [txt sprintf('          <col width="30%%"/>\n')];
    txt = [txt sprintf('          <col width="25%%"/>\n')];
  else
    txt = [txt sprintf('          <col width="15%%"/>\n')];
    txt = [txt sprintf('          <col width="20%%"/>\n')];
    txt = [txt sprintf('          <col width="20%%"/>\n')];
    txt = [txt sprintf('          <col width="45%%"/>\n')];
  end
  txt = [txt sprintf('        </colgroup>\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="%d"><h3>%s</h3></th>\n', colspan, name)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<td bgcolor="#B9C6DD" colspan="%d">%s</td>\n', colspan, description)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Key</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Default Value</th>\n')];
  txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Options</th>\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Description</th>\n')];
  if hasProperties
    txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Properties</th>\n')];
  end
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
  
  
  % pre-sort params by origin
  allParams = plist();
  for kk=1:pl.nparams
    p = pl.params(kk);
    origin = p.origin;
    if isempty(origin)
      origin = 'unknown';
    end    
    currentParams = allParams.find(origin);
    allParams.pset(origin, [currentParams p]);    
  end
    
  for kk=1:allParams.nparams
    
    params = allParams.params(kk).val;   
    origin = params(1).origin;
    
    % group header
    txt = [txt sprintf('          <tr valign="top" ><td align="center" bgcolor="#CCCCFF" colspan="%d">%s</td></tr>\n', colspan, origin)];
    
    for jj=1:numel(params)
      txt = [txt rowForParam(params(jj), hasProperties)];
    end
  end % End loop over params
  
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  
  % example table
  txt = [txt sprintf('      <p>\n')];  
  txt = [txt sprintf('      <table cellpadding="4">\n')];
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#FFEE99"><h3>Example</h3></th>\n')];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  txt = [txt sprintf('        <tbody>\n')];
  txt = [txt sprintf('          <tr bgcolor="#FFEE99"><td>%s</td></tr>\n', string(pl))];
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  txt = [txt sprintf('      </p>\n')];
  
  
  
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
    html = [html sprintf('    <title>Plist Report: %s</title>\n', name)];
    html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
    html = [html sprintf('  </head>\n\n')];
    
    html = [html sprintf('  <body>\n\n')];
    
    html = [html txt]; % table
    
    html = [html sprintf('  </body>\n')];
    html = [html sprintf('</html>')];
    web(html, '-new');
    
  end
  
end

function [state, colspan] = hasProperties(pl)
  state = false;
  colspan       = 4;
  for ii=1:numel(pl.params)
    if ~isempty(pl.params(ii).getProperties())
      state = true;
      colspan       = 5;
      break
    end
  end
end

function txt = rowForParam(param, hasProperties)
  
  txt = '';
  
  txt = [txt sprintf('          <tr valign="top">\n')];
  if ischar(param.key)
    kNames = param.key;
  else
    kNames = param.key{1};
    for kn=2:numel(param.key)
      kNames = sprintf('%s, %s', kNames, param.key{kn});
    end
  end
  % Add 'key'
  txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', kNames)];
  
  % Add default value
  v = param.getVal();
  txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', utils.helper.val2str(v, 60))];
  
  % Add options
  if numel(param.getOptions) > 1
    opts = param.getOptions;
    optlist ='<ul>';
    for oo=1:numel(opts)
      optlist = sprintf('%s<li><font color="#1111FF">%s</font></li>', optlist, utils.helper.val2str(opts{oo}));
    end
    optlist = sprintf('%s</ul>', optlist);
    txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n',  optlist)];
  else
    txt = [txt sprintf('            <td bgcolor="#F2F2F2"><i>none</i></td>\n')];
  end
  
  % Add description
  txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', char(strrep(param.desc, '\n', '<br></br>')))];
  
  % Add Properties
  if hasProperties
    props = param.getProperties();
    if isempty(props)
      txt = [txt sprintf('            <td bgcolor="#F2F2F2"></td>\n')];
    else
      proplist ='<ul>';
      fns = fieldnames(props);
      for pp=1:numel(fns)
        proplist = sprintf('%s<li><font color="#1111FF">%s</font> = %s</li>', proplist, fns{pp}, utils.helper.val2str(props.(fns{pp}), 60));
      end
      proplist = sprintf('%s </ul>', proplist);
      txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', proplist)];
    end
  end
  
  txt = [txt sprintf('          </tr>\n')];
end

