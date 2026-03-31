% VIEWDETAILS performs actions on ssm objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: VIEWDETAILS performs actions on <class> objects.
%
%
% CALL:        out = obj.viewDetails(pl)
%              out = viewDetails(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ssm object(s)
%
% OUTPUTS:     out - some output.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'viewDetails')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = viewDetails(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ssm
  [objs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Loop over input objects
  for jj = 1 : numel(objs)
    % Process object jj
    object = objs(jj);
    
    % Build HTML
    txt = buildHTML(object);
    
    web(txt, '-new', '-notoolbar', '-noaddressbox');
    
    
  end % loop over analysis objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, {txt});
end

function html = buildHTML(obj)
  
  helpPath = utils.helper.getHelpPath();
  docStyleFile      = ['file://' helpPath '/ug/docstyle.css'];
  
  html = 'text://<html>';
  
  html = [html sprintf('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n')];
  html = [html sprintf('   "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">\n\n')];
  
  html = [html sprintf('<html lang="en">\n')];
  
  % Head definition
  html = [html sprintf('  <head>\n')];
  html = [html sprintf('    <title>Details for model %s</title>\n', obj.name)];
  html = [html sprintf('    <link rel="stylesheet" type="text/css" href="%s">\n', docStyleFile)];
  html = [html sprintf('  </head>\n\n')];
  
  html = [html sprintf('  <body>\n\n')];
  
  html = [html sprintf('    <a name="top_of_page" id="top_of_page"></a>\n')];
  html = [html sprintf('<h1>Details for model %s</h1>', obj.name)];
  
  html = [html sprintf('<br><p>%s</p>', obj.description)];
  
  % Link-Table of the sections
  html = [html sprintf('    <p><!-- Link-Table of the sections -->\n')];
  html = [html sprintf('      <table border="0" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
  html = [html sprintf('        <tr><th>Sections</th></tr>\n')];
  
  html = [html sprintf('        	<tr><td><a href="#inputs">Inputs</a></td></tr>\n')];
  html = [html sprintf('        	<tr><td><a href="#states">States</a></td></tr>\n')];
  html = [html sprintf('        	<tr><td><a href="#outputs">Outputs</a></td></tr>\n')];
  html = [html sprintf('        	<tr><td><a href="#numparams">Numerical Parameters</a></td></tr>\n')];
  html = [html sprintf('        	<tr><td><a href="#params">Parameters</a></td></tr>\n')];
  
  html = [html sprintf('      </table>\n')];
  html = [html sprintf('    <p>\n\n')];
  
  
  %-------------------------- Inputs
  html = [html sprintf('<h2><a name="inputs">Inputs</a></h2>')];
  title = 'Input Blocks';
  html = [html linksTable(title, {obj.inputs.name}, {obj.inputs.description})];
  for kk=1:numel(obj.inputs)
    block = obj.inputs(kk);
    blockTxt = fixBlockTxt(block.tohtml, title, block.name);
    html = [html blockTxt];
    html = [html backToTop];
  end
  
  % States
  html = [html sprintf('<h2><a name="states">States</a></h2>')];
  title = 'State Blocks';
  html = [html linksTable(title, {obj.states.name}, {obj.states.description})];
  for kk=1:numel(obj.states)
    block = obj.states(kk);
    blockTxt = fixBlockTxt(block.tohtml, title, block.name);
    html = [html blockTxt];
    html = [html backToTop];
  end
  
  % Outputs
  html = [html sprintf('<h2><a name="outputs">Outputs</a></h2>')];
  title = 'Output Blocks';
  html = [html linksTable(title, {obj.outputs.name}, {obj.outputs.description})];
  for kk=1:numel(obj.outputs)
    block = obj.outputs(kk);
    blockTxt = fixBlockTxt(block.tohtml, title, block.name);
    html = [html blockTxt];
  end
  html = [html backToTop];
  
  % Numerical Parameters
  if isempty(obj.numparams.name)
    obj.numparams.setName('Numerical parameters plist');
  end
  if isempty(obj.numparams.description)
    obj.numparams.setDescription('Parameters which have been replaced by their numerical value in the {A,B,C,D} matrices.');
  end
  html = [html sprintf('<h2><a name="numparams">Numerical Parameters</a></h2>')];
  html = [html obj.numparams.tohtml];
  html = [html backToTop];
  
  % Parameters
  if isempty(obj.params.name)
    obj.params.setName('Parameters plist');
  end
  if isempty(obj.params.description)
    obj.params.setDescription('Parameters which are still represented symbolically in the {A,B,C,D} matrices.');
  end
  html = [html sprintf('<h2><a name="params">Parameters</a></h2>')];
  html = [html obj.params.tohtml];
  html = [html backToTop];
  
  % end tag
  html = [html '</body></html>'];
end

function blockTxt = fixBlockTxt(blockTxt, title, name)  
  repTxt = sprintf('name="%s"', utils.helper.genvarname([title name]));
  blockTxt = regexprep(blockTxt, 'name="(\w+)"', repTxt);
end


function html = linksTable(name, links, descriptions)
  
  html = '';
  html = [html sprintf('    <p><!-- Link-Table -->\n')];
  html = [html sprintf('      <table border="0" cellpadding="4" cellspacing="0" class="pagenavtable">\n')];
  html = [html sprintf('        <tr><th>%s</th><th>Description</th</tr>\n', name)];
  
  for ll=1:numel(links)
    link = links{ll};
    desc = descriptions{ll};
    html = [html sprintf('        	<tr><td><a href="#%s">%s</a></td><td>%s</td></tr>\n', utils.helper.genvarname([name link]), link, desc)];
  end
  
  html = [html sprintf('      </table>\n')];
  html = [html sprintf('    <p>\n\n')];
  
end

function html = backToTop()
  helpPath = utils.helper.getHelpPath();
  toTopFile         = ['file://' helpPath '/ug/doc_to_top_up.gif'];
  html = '';
  html = [html sprintf('      <!-- ===== Back to top ===== -->\n')];
  html = [html sprintf('      <a href="#top_of_page">\n')];
  html = [html sprintf('        <img src="%s" border="0" align="bottom" alt="back to top"/>\n', toTopFile)];
  html = [html sprintf('        back to top\n')];
  html = [html sprintf('      </a>\n')];
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  % Create empty plsit
  pl = plist();
  
  
end

% END
