% HIST2M writes a new m-file that reproduces the analysis described in the history object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HIST2M writes a new m-file that reproduces the analysis described
%              in the history object.
%
% CALL:        cmds = hist2m(h);
%
% INPUT:       h    - history object
%
% OUTPUT:      cmds - cell array with the commands to reproduce the data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmds = hist2m(varargin)
  
  import utils.const.*
  
  % Get history objects
  hists = varargin{1};
  
  if nargin >= 2
    stop_option = varargin{2};
  else
    stop_option = 'full';
  end
  
  % Created contains the epochtime in millisecounds and CREATED2INT define
  % the number of the last digits
  CREATED2INT = 1e7;
  
  % get a node list
  [n,a, nodes] = getNodes(hists, stop_option);
  
  % loop over nodes and convert to commands
  ii = 1;
  cmds = {};
  Nnodes = length(nodes);
  
  allNodeHists = [nodes.hist];
  allNodeUUIDs = {allNodeHists.UUID};
  
  while ii <= Nnodes
    node   = nodes(ii);
    
    % The child histories define the number of inputs.
    % Create here the names of the input objects
    % ONLY if the UUID exist in the UUID of the nodes.
    % It might be that the user have defined a 'stop option'
    childHist = node.hist.inhists;
    
    if ~isempty(childHist)
      childUUIDs = {childHist.UUID};
      idx = utils.helper.ismember(childUUIDs, allNodeUUIDs);
      childHist = childHist(idx);
      inNames = zeros(size(childHist));
      for jj=1:length(childHist)
        created = childHist(jj).proctime; %get(hi(j), 'created');
        inNames(jj) = mod(created,CREATED2INT);
      end
    else
      inNames = [];
    end
    
    % Define inputs of writeCmd()
    histMethName = char(nodes(ii).hist.methodInfo.mname);
    histPl       = nodes(ii).histPl;
    outName      = mod(nodes(ii).hist.proctime, CREATED2INT);
    histCl       = nodes(ii).hist.methodInfo.mclass;
    
    cmd = writeCmd(histMethName, histPl, outName, inNames, histCl, stop_option);
    
    if ~iscell(cmd), cmd = {cmd}; end
    cmds = {cmds{:} cmd{:}};
    ii = ii + 1;
    
  end
  
  % now find commands that are duplicated after the '=' and remap those
  % because the processing of plists can introduce more duplicates.
  ncmds = length(cmds);
  
  for j = 1:ncmds
    cmdj = cmds{j};
    % now inspect all other commands prior to this one
    for k = j+1:ncmds
      cmdk = cmds{k};
      if strcmp(cmdj, cmdk)
        cmds{j} = '';
      end
    end
  end

  
  % remove empty commands  
  cmds = cmds(~strcmp('', cmds));
  
  % add the final command to produce a_out
  alast = deblank(strtok(cmds{1}, '='));
  cmds  = [cellstr(sprintf('a_out = %s;', alast)) cmds];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% FUNCTION:    writeCmd                                                       %
%                                                                             %
% DESCRIPTION: write a command-line                                           %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cmd = writeCmd(name, pl, aon, ains, methodclass, stop_option)
  
  ainsStr = '';
  % for i=length(ains):-1:1
  ni = length(ains);
  for i=1:ni
    ainsStr = [ainsStr sprintf('a%d, ', ains(i))];
  end
  
  name = strrep(name, '\_', '_');
  
  if isempty(pl) || isempty(pl.params)
    ainsStr = ainsStr(1:end-2);
    cmd = sprintf('a%d = %s(%s);', aon, name, ainsStr);
  else
    % convert plist to commands
    cmd = plist2cmds(pl, stop_option);
    % the last command will go as input to the method command
    [~,plstr] = strtok(cmd{1});
    plstr = strtrim(plstr);
    cmd = [ sprintf('a%d = %s(%s%s); %% %s', aon, name, ainsStr, strtrim(plstr(2:end-1)),methodclass) cmd(2:end)];
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  
  pl = plist();
  pl.append(plist.HISTORY_TREE_PLIST);
  
end

