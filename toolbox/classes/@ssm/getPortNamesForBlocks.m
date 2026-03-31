% GETPORTNAMESFORBLOCKS returns a list of port names for the given block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: This method returns a list of port names for the given blocks.
%
% CALL:        portNames = getPortNamesForBlocks(blockNames) 
%              portNames = getPortNamesForBlocks(plist)
% 
% INPUTS:
%               blockNames - the name (or cell-array of names) of the
%                            block(s) you wants the ports for. The block
%                            names are checked against either the system
%                            inputs, states or outputs, depending on the
%                            'type' key in the plist.
%                            A special value of 'All' is supported which
%                            returns the ports for all blocks.
% 
% OUTPUTS:
%             portNames - a cell-array of port names.
% 
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'getPortNamesForBlocks')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getPortNamesForBlocks(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all SSM objects and plists
  [obj, ~, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, ~, rest]   = utils.helper.collect_objects(rest, 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get parameters
  blockNames = pl.find('blocks');
  blockType  = pl.find('type');
  
  % If the user didn't specify the block names via the plist, then check the inputs
  if ~isempty(rest) && isempty(blockNames)
    blockNames = rest{1};
  end
  
  if ischar(blockNames)
    blockNames = {blockNames};
  end

  % Special case 'all'
  if numel(blockNames) == 1 && strcmpi(blockNames{1}, 'all')
    
    ports = [];
    ports = [ports obj.inputs.ports];
    ports = [ports obj.states.ports];
    ports = [ports obj.outputs.ports];
        
    varargout{1} = {ports.name};
    return;
    
  end
  
  if isempty(blockNames) 
    error('Please provide at least one block name directly or via the input plist');
  end

  % Initialise the port name cell-array
  portNames = {};
  
  % Search the desired blocks
  switch lower(blockType)
    case 'inputs'
      portNames = [portNames portsForBlocks(obj.inputs, blockNames)];
    case 'states'
      portNames = [portNames portsForBlocks(obj.states, blockNames)];
    case 'outputs'
      portNames = [portNames portsForBlocks(obj.outputs, blockNames)];
    case 'all'
      portNames = [portNames portsForBlocks(obj.inputs, blockNames)];
      portNames = [portNames portsForBlocks(obj.states, blockNames)];
      portNames = [portNames portsForBlocks(obj.outputs, blockNames)];
    otherwise
      error('Unknown block type specified: %s', blockType);
  end
  
  
  varargout{1} = portNames;
  
end

function portNames = portsForBlocks(blocks, blockNames)
  portNames = {};
  allNames = {blocks.name};
  for kk=1:numel(blockNames)
    idx = strcmpi(blockNames{kk}, allNames);
    if any(idx)
      names = {blocks(idx).ports.name};
      portNames = [portNames names];
    end
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
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
  
  % Default plist
  pl = plist();
  
  % Block names
  p = param({'blocks',['A block name or cell-array of block names']}, paramValue.EMPTY_STRING);
  pl.append(p);
    
  % Block type
  p = param({'type',['The type of block to search']},  {4, {'inputs', 'states', 'outputs', 'all'}, paramValue.SINGLE});
  pl.append(p);
  
  
end

% END
