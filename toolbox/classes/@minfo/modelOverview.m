% MODELOVERVIEW prepares an html overview of a built-in model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MODELOVERVIEW prepares an html overview of a built-in model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = modelOverview(varargin)
  
  % Get minfo objects
  objs = utils.helper.collect_objects(varargin(:), 'minfo');
  
  if numel(objs) > 1
    error('### Only works for one info object');
  end
  
  if nargin == 2
    browser = varargin{2};
  else
    browser = true;
  end
  txts = html(objs(1),browser);
  
  % display the objects
  if nargout > 0
    varargout{1} = txts;
  elseif nargout == 0;
    disp(txts);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = html(ii, browser)
  
  modelFcn = ii.mname;
  
  txt = '';
  % Page header
  txt = [txt pageHeader(ii)];
  
  % Table of the navigation (top)
  if browser
    txt = [txt topNavigation(ii)];
  end
  
  % Title
  txt = [txt sprintf('    <h1 class="title">Model Report for %s</h1>\n', ii.mname)];
  txt = [txt sprintf('    <hr>\n\n')];

  
  % Description
  desc = feval(modelFcn, 'description');
  txt  = [txt sprintf('<p>%s</p>\n', desc)];
  
  % Documentation
  doc = feval(modelFcn, 'doc');
  txt = [txt sprintf('<p>%s</p>\n', doc)];
  
  % Model version table
  txt = [txt modelVersionsTable(ii, modelFcn)];
  
  % Table of the minfo object
  txt = [txt minfoSummaryTable(ii)];
  
  % built-in model constructor plist. Take the ssm one since it adds some
  % additional keys
  bii = ssm.getInfo('ssm', 'From Built-in Model');
  bcpl = bii.plists(1);
  
  % Section for each version
  versionTable = feval(modelFcn, 'versionTable');
  nVersions = numel(versionTable)/2;
  for ll=1:nVersions
    version = versionTable{2*ll-1};
    utils.helper.msg(utils.const.msg.PROC1, '* generating documentation for version [%s]', version);
    desc = feval(modelFcn, 'describe', version);
    pl = feval(modelFcn, 'plist', version);
    pl.remove('VERSION');
    
    txt = [txt '<hr/>'];
    txt = [txt sprintf('<a name="%s"/><h2>%s</h2></a>\n', strrep(version, ' ', ''), version)];
    
    % description
    verFcn = utils.models.functionForVersion([], versionTable, version, []);
    % description for version
    desc = feval(verFcn, 'description');
    txt = [txt sprintf('<p>%s</p>\n', desc)];
    
    % extras for SSM
    if strcmpi(ii.mclass, 'ssm')
      txt = [txt ssmExtras(verFcn)];
    end
    
    % plist table
    keys = bcpl.getKeys;
    pldisplay = copy(pl, 1);
    for kk=1:numel(keys)
      if pl.isparam_core(keys{kk});
        pldisplay.remove(keys{kk});
      end
    end
    txt = [txt pldisplay.tohtml];
    
    % Submodels table
    txt = [txt subModelsTable(ii, modelFcn, version)];
    
    % Back to top
    txt = [txt backToTopLink()];
    
  end
  
  
  % Table of the navigation (bottom)
  if browser
    txt = [txt bottomNavigation(ii)];
  end
  
  % Footer
  txt = [txt sprintf('  <p class="copy">&copy;LTP Team</p>\n')];
  
  txt = [txt sprintf('  </body>\n')];
  txt = [txt sprintf('</html>')];
  
end

function blockTxt = fixBlockTxt(blockTxt, title, name)  
  repTxt = sprintf('name="%s"', utils.helper.genvarname([title name]));
  blockTxt = regexprep(blockTxt, 'name="(\w+)"', repTxt);
end

function txt = ssmExtras(verFcn)
  
  txt = '';
  %-------------------------- Inputs
  txt = [txt sprintf('<h2><a name="inputs">Inputs</a></h2>')];
  try
    inputs = verFcn('inputs');
    title = 'Input Blocks';
    txt = [txt linksTable(title, {inputs.name}, {inputs.description})];
    for kk=1:numel(inputs)
      block =inputs(kk);
      blockTxt = fixBlockTxt(block.tohtml, title, inputs(kk).name);
      txt = [txt blockTxt];
      txt = [txt backToTopLink];
    end
  catch
    txt = [txt '<b>No information about inputs</b><br>'];
  end
  
  % States
  txt = [txt sprintf('<h2><a name="states">States</a></h2>')];
  try
    states = verFcn('states');
    title = 'State Blocks';
    txt = [txt linksTable(title, {states.name}, {states.description})];
    for kk=1:numel(states)
      block = states(kk);
      blockTxt = fixBlockTxt(block.tohtml, title, states(kk).name);
      txt = [txt blockTxt];
      txt = [txt backToTopLink];
    end
  catch
    txt = [txt '<b>No information about states</b><br>'];
  end
  
  % Outputs
  txt = [txt sprintf('<h2><a name="outputs">Outputs</a></h2>')];
  try
    outputs = verFcn('outputs');
    title = 'Output Blocks';
    txt = [txt linksTable(title, {outputs.name}, {outputs.description})];
    for kk=1:numel(outputs)
      block = outputs(kk);
      blockTxt = fixBlockTxt(block.tohtml, title, outputs(kk).name);
      txt = [txt blockTxt];
    end
    txt = [txt backToTopLink];
  catch
    txt = [txt '<b>No information about outputs</b><br>'];
  end
  
  % Parameters
  txt = [txt sprintf('<h2><a name="inputs">Physical Parameters</a></h2>')];
  try
    params = verFcn('parameters');
    
    
    txt = [txt sprintf('    <!-- Parameter List Table -->\n')];
    txt = [txt sprintf('    <p>\n')];
    txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
    txt = [txt sprintf('        <colgroup>\n')];
    txt = [txt sprintf('          <col width="15%%"/>\n')];
    txt = [txt sprintf('          <col width="20%%"/>\n')];
    txt = [txt sprintf('          <col width="20%%"/>\n')];
    txt = [txt sprintf('          <col width="45%%"/>\n')];
    txt = [txt sprintf('        </colgroup>\n')];
    
    txt = [txt sprintf('        <thead>\n')];
    txt = [txt sprintf('        	<tr valign="top">\n')];
    txt = [txt sprintf('        		<th bgcolor="#B9C6DD" colspan="4"><h3>Physical Parameters</h3></th>\n')];
    txt = [txt sprintf('      	  </tr>\n')];
    txt = [txt sprintf('        	<tr valign="top">\n')];
    txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Name</th>\n')];
    txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Default Value</th>\n')];
    txt = [txt sprintf('        		<th bgcolor="#D7D7D7">Description</th>\n')];
    txt = [txt sprintf('      	  	<th bgcolor="#D7D7D7">Units</th>\n')];
    txt = [txt sprintf('        	</tr>\n')];
    txt = [txt sprintf('        </thead>\n')];
    
    
    txt = [txt sprintf('        <tbody>\n')];
    for kk=1:numel(params.names)
      txt = [txt sprintf('          <tr valign="top">\n')];
      txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', params.names{kk})];
      txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', utils.helper.mat2str(params.values(kk)))];
      txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', params.descriptions{kk})];
      % check units, because they can be empty
      if ~isempty(params.units)
        txt = [txt sprintf('            <td bgcolor="#F2F2F2">%s</td>\n', char(params.units(kk)))];
      else
        txt = [txt sprintf('            <td bgcolor="#F2F2F2"></td>\n')];
      end
      txt = [txt sprintf('          </tr>\n')];
    end
    txt = [txt sprintf('        </tbody>\n')];
    txt = [txt sprintf('      </table>\n')];
  catch
    txt = [txt '<b>No information about physical parameters</b><br>'];
  end
  
  txt = [txt backToTopLink];
  
  
end


function html = linksTable(name, links, descriptions)
  
  html = '';
  html = [html sprintf('    <p><!-- Link-Table -->\n')];
  html = [html sprintf('      <table border="1" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
  html = [html sprintf('        <tr><th>%s</th><th>Description</th</tr>\n', name)];
  
  for ll=1:numel(links)
    link = links{ll};
    desc = descriptions{ll};
    html = [html sprintf('        	<tr><td><a href="#%s">%s</a></td><td>%s</td></tr>\n', utils.helper.genvarname([name link]), link, desc)];
  end
  
  html = [html sprintf('      </table>\n')];
  html = [html sprintf('    <p>\n\n')];
  
end

function txt = backToTopLink()
  
  persistent outtxt
  
  if isempty(outtxt)
    helpPath = utils.helper.getHelpPath();
    toTopFile         = ['file://' helpPath '/'];
    
    outtxt = '';
    outtxt = [outtxt sprintf('      <!-- ===== Back to top ===== -->\n')];
    outtxt = [outtxt sprintf('      <a href="#top_of_page">\n')];
    outtxt = [outtxt sprintf('        <img src="%s" border="0" align="bottom" alt="back to top"/>\n', fullfile(toTopFile, 'ug', 'doc_to_top_up.gif'))];
    outtxt = [outtxt sprintf('        back to top\n')];
    outtxt = [outtxt sprintf('      </a>\n')];
    outtxt = [outtxt sprintf('    </p>\n\n')];
    outtxt = [outtxt sprintf('    <br>\n\n')];
    outtxt = [outtxt sprintf('    <br>\n\n')];
  end
  
  txt = outtxt;
end

function txt = pageHeader(ii)
  txt = '';
  txt = [txt sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
  txt = [txt sprintf('   "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n\n')];
  
  txt = [txt sprintf('<html lang="en">\n')];
  
  % Head definition
  helpPath = utils.helper.getHelpPath();
  docStyleFile = strcat('file://', helpPath, '/ug/docstyle.css');
  txt = [txt sprintf('  <head>\n')];
  txt = [txt sprintf('    <title>Model Report for %s/%s</title>\n', ii.mclass, ii.mname)];
  txt = [txt sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
  txt = [txt sprintf('  </head>\n\n')];
  
  txt = [txt sprintf('  <body>\n\n')];
  
  txt = [txt sprintf('    <a name="top_of_page" id="top_of_page"></a>\n')];
  txt = [txt sprintf('    <p style="font-size:1px;">&nbsp;</p>\n\n')];
  
end

function txt = topNavigation(ii)
  
  txt = '';
  txt = [txt sprintf('    <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n')];
  txt = [txt sprintf('      <tr>\n')];
  txt = [txt sprintf('        <td valign="baseline"><b>LTPDA Toolbox</b></td>\n')];
  txt = [txt sprintf('        <td><a href="file://%s">contents</a></td>\n', which('helptoc.html'))];
  txt = [txt sprintf('        <td valign="baseline" align="right"><a href=\n')];
  txt = [txt sprintf('            "file://%s"><img src=\n', which('class_desc_main.html'))];
  txt = [txt sprintf('            "file://%s" border="0" align="bottom" alt="Class descriptions"></img></a>&nbsp;&nbsp;&nbsp;<a href=\n', which('b_prev.gif'))];
  txt = [txt sprintf('            "file://%s"><img src=\n', which(['class_desc_' ii.mclass '.html']))];
  txt = [txt sprintf('            "file://%s" border="0" align="bottom" alt="%s Class"></a></td>\n', which('b_next.gif'), upper(ii.mclass))];
  txt = [txt sprintf('      </tr>\n')];
  txt = [txt sprintf('    </table>\n\n')];
  
  
end

function txt = bottomNavigation(ii)
  
  txt = '';
  txt = [txt sprintf('  <br>\n')];
  txt = [txt sprintf('  <table class="nav" summary="Navigation aid" border="0" width="100%%" cellpadding="0" cellspacing="0">\n')];
  txt = [txt sprintf('    <tr valign="top">\n')];
  txt = [txt sprintf('      <td align="left" width="20"><a href=\n')];
  txt = [txt sprintf('          "file://%s"><img src=\n', which('class_desc_main.html'))];
  txt = [txt sprintf('          "file://%s" border="0" align="bottom" alt=\n', which('b_prev.gif'))];
  txt = [txt sprintf('          "Class descriptions"></a>&nbsp;</td>\n')];
  txt = [txt sprintf('      <td align="left">Class descriptions</td>\n')];
  txt = [txt sprintf('      <td>&nbsp;</td>\n')];
  txt = [txt sprintf('      <td align="right">%s Class</td>\n', upper(ii.mclass))];
  txt = [txt sprintf('      <td align="right" width="20"><a href=\n')];
  txt = [txt sprintf('          "file://%s"><img src=\n', which('class_desc_ao.html'))];
  txt = [txt sprintf('          "file://%s" border="0" align="bottom" alt=\n', which('b_next.gif'))];
  txt = [txt sprintf('          "%s Class"></a></td>\n', upper(ii.mclass))];
  txt = [txt sprintf('    </tr>\n')];
  txt = [txt sprintf('  </table><br>\n')];
end

function txt = minfoSummaryTable(ii)
  
  txt = '';
  txt = [txt sprintf('    <p><!-- Table of the minfo object -->\n')];
  txt = [txt sprintf('      <table cellspacing="0" class="body" cellpadding="2" border="0" width="60%%">\n')];
  txt = [txt sprintf('        <colgroup>\n')];
  txt = [txt sprintf('          <col width="25%%"/>\n')];
  txt = [txt sprintf('          <col width="75%%"/>\n')];
  txt = [txt sprintf('        </colgroup>\n')];
  txt = [txt sprintf('        <thead>\n')];
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <th class="categorylist" colspan="2">Some information of the model %s are listed below:</th>\n', ii.mname)];
  txt = [txt sprintf('          </tr>\n')];
  txt = [txt sprintf('        </thead>\n')];
  txt = [txt sprintf('        <tbody>\n')];
  txt = [txt sprintf('          <!-- Property: ''mclass'' -->\n')];
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td bgcolor="#f3f4f5">Class name</td>\n')];
  txt = [txt sprintf('            <td bgcolor="#f3f4f5">%s</td>\n', ii.mclass)];
  txt = [txt sprintf('          </tr>\n')];
  txt = [txt sprintf('          <!-- Property: ''mname'' -->\n')];
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">Method name</td>\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">%s</td>\n', ii.mname)];
  txt = [txt sprintf('          </tr>\n')];
  txt = [txt sprintf('          <!-- Property: ''mpackage'' -->\n')];
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">Package name</td>\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">%s</td>\n', ii.mpackage)];
  txt = [txt sprintf('          </tr>\n')];
  txt = [txt sprintf('          <!-- Property: ''mversion'' -->\n')];
  txt = [txt sprintf('          <tr valign="top">\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">VCS Version</td>\n')];
  txt = [txt sprintf('            <td bgcolor="#ffffff">%s</td>\n', ii.mversion)];
  txt = [txt sprintf('          </tr>\n')];
  txt = [txt sprintf('        </tbody>\n')];
  txt = [txt sprintf('      </table>\n')];
  txt = [txt sprintf('    </p>\n\n')];
end


function txt = modelVersionsTable(ii, modelFcn)
  txt = '';
  txt = [txt sprintf('    <p><!-- Link-Table of the sets -->\n')];
  txt = [txt sprintf('      <table border="1" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
  txt = [txt sprintf('        <tr><th>Model Versions</th><th>Description</th></tr>\n')];
  versionTable = feval(modelFcn, 'versionTable');
  nVersions = numel(versionTable)/2;
  for ll=1:nVersions
    version = versionTable{2*ll-1};
    verFcn = utils.models.functionForVersion([], versionTable, version, []);
    % description for version
    desc = feval(verFcn, 'description');
    txt = [txt sprintf('        	<tr><td><a href="#%s">%s</a></td><td>%s</td></tr>\n', strrep(version, ' ', ''), version, desc)];
  end
  txt = [txt sprintf('      </table>\n')];
  txt = [txt sprintf('    <p>\n\n')];
end

function txt = subModelsTable(ii, modelFcn, version)
  
  verinfo = feval(modelFcn, 'info', version);
  children = verinfo.children;
  txt = '';
  if numel(children)==0
    return
  end
  
  txt = [txt sprintf('<p><table border="1" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
  txt = [txt sprintf(' <tr><th>Sub-models</th><th>Version</th><th>Description</th></tr>\n')];
  for jj=1:numel(children)
    cii = children(jj);
    % description for version
    desc = feval(cii.mname, 'description');
    cver = cii.plists.find('VERSION');
    txt = [txt sprintf('  <tr><td><a href="matlab:utils.models.displayModelOverview(''%s'')">%s</a></td><td>%s</td><td>%s</td></tr>\n', cii.mname, cii.mname, cver, desc)];
  end
  txt = [txt sprintf('</table>\n')];
  txt = [txt sprintf('</p>\n\n')];
  
end



