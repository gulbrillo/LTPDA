% GETNODES converts a history object to a nodes structure suitable for plotting as a tree.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETNODES converts a history object to a nodes structure suitable
%              for plotting as a tree.
%
% CALL:        [n,a, nodes] = getNodes(hist, stop_option);
%
% INPUT:       hist:        hisoty-object
%              stop_option: - 'File'          ignores the history steps
%                                             below load-history step
%                           - 'Repo'          ignores the history steps
%                                             below retrieve-history step
%                           - 'File Repo'     both steps above
%                           -  N              maximun depth
%
% OUTPUT:      n:     A vector of parent pointers
%              a:     Number of nodes
%              nodes: Struct of the nodes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getNodes(varargin)
  
  import utils.const.*
  
  if nargin == 1
    currHist      = varargin{1}; % history object
    stop_option   = 'full';      % stop option
  elseif nargin == 2
    currHist      = varargin{1}; % history object
    stop_option   = varargin{2}; % stop option
  else
    error('### Unknown number of inputs')
  end
  
  parentUUID = '';          % init: UUID of the parent node (tree up)
  numOfNodes = 1;           % init: Number of nodes
  nodes      = {};          % init: Array of node structures
  depth      = 0;           % init: Current depth of the tree
  allUUIDs   = {};          % init: Cell array for all UUIDs
  [numOfNodes, nodes, UUIDs] = internalRecursion(currHist, numOfNodes, nodes, allUUIDs, parentUUID, depth, stop_option);
  nodes = [nodes{:}];
  
  % Sort the nodes by 'proctime'
  h = [nodes.hist];
  pTime = [h.proctime];
  [~, idx] = sort(pTime, 2, 'descend');
  nodes = nodes(idx);
  
  % Set outputs
  varargout{1} = [nodes.parentUUIDs]; % --> n
  varargout{2} = numOfNodes;
  varargout{3} = nodes;
end

function [numOfNodes, nodes, allUUIDs] = internalRecursion(currHist, numOfNodes, nodes, allUUIDs, parentUUID, depth, stop_option)
  
  histPl = currHist.plistUsed;
  
  % Check if this is a new history step or not.
  if ~utils.helper.ismember(currHist.UUID, allUUIDs)
    allUUIDs = [allUUIDs {currHist.UUID}];
  else
    % We have already collected this history step
    idx = strcmp(currHist.UUID, allUUIDs);
    n = nodes{idx};
    n.parentUUIDs = [n.parentUUIDs, {parentUUID}];
    nodes{idx} = n;
    return
  end
  
  ih  = currHist.inhists;
  
  % Create new Node structure
  newNode = struct('parentUUIDs', -1, 'histPl', -1, 'hist', -1, 'childrenUUIDs', -1);
  newNode.parentUUIDs = parentUUID;
  if ~isempty(ih)
    newNode.childrenUUIDs = {ih.UUID};
  else
    newNode.childrenUUIDs = {};
  end
  newNode.histPl        = histPl;
  newNode.hist          = currHist;
  
  nodes = [nodes {newNode}];
  
  if mod(numOfNodes, 40) == 0
    utils.helper.msg(utils.const.msg.PROC1, '%05d', numOfNodes);
  end
  
  % Now decide what to do with my children
  for ii=1:numel(ih)
    
    if  (strcmpi(stop_option, 'File') || strcmpi(stop_option, 'File Repo')) && ...
        isa(histPl, 'plist') && isparam_core(histPl, 'filename')
      % do nothing
    elseif (strcmpi(stop_option, 'Repo') || strcmpi(stop_option, 'File Repo')) && ...
        isa(histPl, 'plist') && (isparam_core(histPl, 'conn') || isparam_core(histPl, 'hostname'))
      % do nothing
    else
      % recurse the tree
      if depth < 1e20
        [numOfNodes, nodes, allUUIDs] = internalRecursion(ih(ii), numOfNodes+1, nodes, allUUIDs, currHist.UUID, depth+1, stop_option);
      end
    end
    
  end
  
end







