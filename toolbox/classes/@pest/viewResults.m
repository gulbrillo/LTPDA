% VIEWRESULTS displays the content of the pest object as an html report.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  Displays the values in the pest as an html report.
%
% CALL 
%                viewResults(pest_obj,pl)
%         html = viewResults(pest_obj,pl)
%
% INPUTS
%           pest_obj - pest object
%           pl       - plist
%
%
%<a href="matlab:utils.helper.displayMethodInfo('pest', 'viewResults')">ParametersDescription</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = viewResults(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [pests, pest_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  p = copy(pests, nargout);
  
    txt = '';
  
  name = p.name;
  if isempty(name)
    name = 'Unknown Pest';
  end
  
  description = p.description;
  if isempty(description)
    description = '<i>no description</i>';
  end
  
  %-------------- Parameter table
  if nargin > 1 && ischar(anchor)
    txt = [txt sprintf('    <a name="%s"></a>\n', anchor)];
  end
  txt = [txt sprintf('    <!-- Parameter Table: %s -->\n', name)];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" border="2">\n')];
  txt = [txt sprintf('        <colgroup>\n')];
  txt = [txt sprintf('          <col width="15%%"/>\n')];
  txt = [txt sprintf('          <col width="20%%"/>\n')];
  txt = [txt sprintf('          <col width="20%%"/>\n')];
  txt = [txt sprintf('        </colgroup>\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="4"><h3>Parameter Values</h3></th>\n')];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="4"><h3>%s</h3></th>\n',  name)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<td bgcolor="#B9C6DD" colspan="4">%s</td>\n',  description)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('      	  	<th align="center" bgcolor="#D7D7D7">Name</th>\n')];
  txt = [txt sprintf('      	  	<th align="center" bgcolor="#D7D7D7">Units</th>\n')];
  txt = [txt sprintf('        		<th align="center" bgcolor="#D7D7D7">Recovered Value</th>\n')];
  txt = [txt sprintf('        		<th align="center" bgcolor="#D7D7D7">Sigma</th>\n')];
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
  for kk=1:numel(p.names)
    txt = [txt sprintf('          <tr valign="top">\n')];
    txt = [txt sprintf('            <td align="left" bgcolor="#F2F2F2">%s</td>\n', p.names{kk})];
    txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%s</td>\n', p.yunits(kk).char)];
    txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%g</td>\n', p.y(kk))];
    txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%g</td>\n', p.dy(kk))];
    txt = [txt sprintf('          </tr>\n')];    
  end
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  
  %----------------- Covariance table
  if nargin > 1 && ischar(anchor)
    txt = [txt sprintf('    <a name="%s"></a>\n', anchor)];
  end
  txt = [txt sprintf('    <!-- Covariance Table: %s -->\n', name)];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="%d"><h3>COVARIANCE</h3></th>\n',  numel(p.names)+1)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="%d"><h3>%s</h3></th>\n',  numel(p.names)+1, name)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<td bgcolor="#B9C6DD" colspan="%d">%s</td>\n',  numel(p.names)+1, description)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
    txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7"></th>\n')];
  for kk=1:numel(p.names)
    txt = [txt sprintf('      	  	<th align="center" bgcolor="#D7D7D7">%s</th>\n', p.names{kk})];
  end
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
    
  for kk=1:numel(p.names)
    txt = [txt sprintf('          <tr valign="top">\n')];
    txt = [txt sprintf('            <td align="left" bgcolor="#D7D7D7">%s</td>\n', p.names{kk})];
    for jj=1:numel(p.names)
      txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%g</td>\n', p.cov(kk,jj))];
    end
    txt = [txt sprintf('          </tr>\n')];
    
  end
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  
  %------------------ Other params
  if nargin > 1 && ischar(anchor)
    txt = [txt sprintf('    <a name="%s"></a>\n', anchor)];
  end
  txt = [txt sprintf('    <!-- Values Table: %s -->\n', name)];
  txt = [txt sprintf('    <p>\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" border="2">\n')];
  
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="%d"><h3>Other Values</h3></th>\n',  numel(p.names)+1)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="%d"><h3>%s</h3></th>\n',  numel(p.names)+1, name)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('        		<td bgcolor="#B9C6DD" colspan="%d">%s</td>\n',  numel(p.names)+1, description)];
  txt = [txt sprintf('      	  </tr>\n')];
  txt = [txt sprintf('        	<tr valign="top">\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Name</th>\n')];
  txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Value</th>\n')];
  txt = [txt sprintf('        	</tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  
  
  txt = [txt sprintf('        <tbody>\n')];
    
  % chi2
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td align="left" bgcolor="#D7D7D7">chi2</td>\n')];
  txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%g</td>\n', p.chi2)];
  txt = [txt sprintf('          </tr>\n')];
    
  % dof
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td align="left" bgcolor="#D7D7D7">dof</td>\n')];
  txt = [txt sprintf('            <td align="center" bgcolor="#F2F2F2">%g</td>\n', p.dof)];
  txt = [txt sprintf('          </tr>\n')];
  
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
    html = [html sprintf('    <title>Parameter Estimates Report: %s</title>\n', name)];
    html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
    html = [html sprintf('  </head>\n\n')];
    
    html = [html sprintf('  <body>\n\n')];
    
    html = [html txt]; % table
        
    html = [html sprintf('  </body>\n')];
    html = [html sprintf('</html>')];
    web(html);
    
  end
  
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % p = param({'chain',['Insert an array containing the parameters to plot. If left empty,'...
  %     'then by default will plot the chains of every parameter. If set to zero then no chains are plotted. (note: The loglikelihood is stored '...
  %     'in the first column)']}, paramValue.DOUBLE_VALUE([]));
  % pl.append(p);
  
  
end
