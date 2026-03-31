% SSM2DOT converts a statespace model object a DOT file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SSM2DOT converts a statespace model object a DOT file.
%
% CALL:        ssm2dot(ssm, options);
%
% INPUTS:      ssm     - ssm object
%              options - plist of options
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'ssm2dot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ssm2dot(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [inputSSMs, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest, 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  options = combine(pl, getDefaultPlist());
  
  
  filename = find(options, 'filename');
  if isempty(filename)
    error('### Please specify an output filename in the plist');
  end
  
  statesOn = find(options, 'States');
  if strcmpi(statesOn, 'yes')
    statesOn = true;
  else
    statesOn = false;
  end
  
  if numel(inputSSMs) ~= 1
    error('### please input (only) one SSM object.');
  end
  
  % Find the last assemble in the history
  [n,a, nodes] = getNodes(inputSSMs.hist, 'full');
  ssmNodes = findAssembleInputs(nodes, 1);
  % if we only get one node there must not be any assemble blocks so we can
  % just use the first node.
  if length(ssmNodes)==1 || isempty(ssmNodes)
    ssmNodes = 1;
  end
  
  colors = {'blueviolet', 'chartreuse4', 'firebrick3', 'darkorange', 'navyblue', 'aquamarine3', 'deepskyblue'};
  
  % What info do we need?
  sss(length(ssmNodes),1) = ssm;
  for j=1:length(ssmNodes)
    node = nodes(ssmNodes(j));
    % Collect the nodes to execute
    % and convert to commands
    cmds = hist2m(node.hist);
    % execute each command
    for kk=numel(cmds):-1:1
      eval(cmds{kk});
    end
    % add to outputs
    sss(j) = a_out;
  end
  % Write .dot file
  fd = fopen(filename, 'w+');
  % write header
  fprintf(fd, 'digraph G \n{\n');
  fprintf(fd, '\trankdir="LR";\n');
  fprintf(fd, '\tnode [style=filled, fillcolor=white fixedsize=false width=0.5 fontsize=16 shape=rectangle];\n');
  fprintf(fd, '\tedge [penwidth=5];\n');
  fprintf(fd, '\n\n');
  % Write block set
  for j=1:length(ssmNodes)
    % get the object
    ss = sss(j);
    inputblocks  = ss.inputnames;
    inputvars    = ss.inputvarnames;
    outputblocks = ss.outputnames;
    outputvars   = ss.outputvarnames;
    ssnames      = ss.ssnames;
    ssvarnames   = ss.ssvarnames;
    % Create sub graphs
    fprintf(fd, '\tsubgraph cluster%d {\n', j);
    fprintf(fd, '\t\tlabel="%s";\n', ss.name);
    fprintf(fd, '\t\tfontcolor=black;\n');
    fprintf(fd, '\t\tcolor=gray60;\n');
    fprintf(fd, '\t\tstyle=filled;\n');
    for k=1:numel(inputblocks)
      fprintf(fd, '\t\tsubgraph cluster%d%d_in {\n', j, k);
      fprintf(fd, '\t\t\tlabel="%s";\n', inputblocks{k});
      fprintf(fd, '\t\t\tstyle=filled;\n');
      fprintf(fd, '\t\t\tcolor=yellow1;\n');
      fprintf(fd, '\t\t\tfontcolor=black;\n');
      for l=1:numel(inputvars{k})
        fprintf(fd, '\t\t\tssm_in_%d_%d_%d [label="%s"];\n', j,k,l,inputvars{k}{l});
      end
      fprintf(fd, '\t\t}\n');
    end
    for k=1:numel(outputblocks)
      fprintf(fd, '\t\tsubgraph cluster%d%d_out {\n', j, k);
      fprintf(fd, '\t\t\tlabel="%s";\n', outputblocks{k});
      fprintf(fd, '\t\t\tstyle=filled;\n');
      fprintf(fd, '\t\t\tcolor=lightblue1;\n');
      for l=1:numel(outputvars{k})
        fprintf(fd, '\t\t\tssm_out_%d_%d_%d [label="%s"];\n', j,k,l,outputvars{k}{l});
      end
      fprintf(fd, '\t\t}\n');
    end
    if statesOn
      for k=1:numel(ssnames)
        fprintf(fd, '\t\tsubgraph cluster%d%d_state {\n', j, k);
        fprintf(fd, '\t\t\tlabel="%s";\n', ssnames{k});
        fprintf(fd, '\t\t\tstyle=filled;\n');
        fprintf(fd, '\t\t\tcolor=wheat1;\n');
        for l=1:numel(ssvarnames{k})
          fprintf(fd, '\t\t\tssm_state_%d_%d_%d [label="%s"];\n', j,k,l,ssvarnames{k}{l});
        end
        fprintf(fd, '\t\t}\n');
      end
    end
    fprintf(fd, '\t}\n');
    fprintf(fd, '\n\n');
  end
  % Write node list
  fprintf(fd, '\n');
  fprintf(fd, '\n');
  nl = 1;
  for j=1:length(ssmNodes)
    % get the object
    ss = sss(j);
    inputblocks  = ss.inputnames;
    inputvars    = ss.inputvarnames;
    % Now join outputs to inputs
    for k=1:numel(inputblocks)
      iblock = inputblocks{k};
      % look for a matching output block
      for oj = 1:length(ssmNodes)
        oss = sss(oj);
        outputblocks = oss.outputnames;
        outputvars   = oss.outputvarnames;
        for ok=1:numel(outputblocks)
          if strcmp(outputblocks{ok}, iblock)
            % make a connection from each output to each input
            for ol = 1:numel(outputvars{ok})
              col = colors{mod(nl, numel(colors))+1};
              % draw a line
              fprintf(fd, 'ssm_out_%d_%d_%d -> ssm_in_%d_%d_%d [color="%s"];\n', oj, ok, ol, j, k, ol, col);
              nl = nl + 1;
            end
          end
        end
      end
    end
  end
  fprintf(fd, '\n');
  fprintf(fd, '\n');
  % close graph
  fprintf(fd, '}\n');
  % Close
  fclose(fd);
  
end

%--------- Get the input SSMs to all assemble blocks
function idx = findAssembleInputs(nodes, an)
  idx = [];
  % get children
  children = findChildNodes(nodes, an, '');
  % find all sub-assembles or ssm end points
  for j=1:numel(children)
    ch = children(j);
    subasmbl = findChildNodes(nodes, ch, 'assemble');
    if isempty(subasmbl)
      idx = [idx ch];
    else
      idx = [idx findAssembleInputs(nodes, ch)];
    end
  end
end

%---- Find particular child nodes
function idx = findChildNodes(nodes, pn, name)
  
  idx = [];
  if strcmp(nodes(pn).hist.methodInfo.mname, name)
    idx = [idx pn];
  end
  
  parentNode = nodes(pn);
  inhists = parentNode.hist.inhists;
  if isempty(inhists)
    idx = [];
    return;
  end
  
  allHists = [nodes.hist];
  allUUIDs = {allHists.UUID};
  idx = find(utils.helper.ismember(allUUIDs, {inhists.UUID}));
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'filename', 'The output filename to save the graphic to.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'states', 'Draw the states of each model.'}, paramValue.TRUE_FALSE);
  p.val.setValIndex(2);
  pl.append(p);
end

