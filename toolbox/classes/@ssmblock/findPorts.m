% MAKEPORTINDEX gives indexes of selected in a series of list in a cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAKEPORTINDEX2 gives a an array of port positions
%
% CALL: [blockNumber portNumber] = makePortIndex(varargin)
%
%       makePortIndex(ssmblock, cellstr)
%       makePortIndex(ssmblock, str)
%
% INPUTS:
%       select - input index:
%                         - cellstr,
%                         - cell array including
%                                 - 'ALL'/'NONE' to index all/no content,
%                                 - chars with port/block names
%                         - a str for one variable name only, 'ALL'/'NONE'
%
% OUTPUTS:
%       blockNumber - block index
%       portNumber  - port index
%
% ***** There are no parameters *****
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [blockNumber portNumber] = findPorts(block, data)
  error('This function is deprecated and will be deleted')


  if ~isa(block, 'ssmblock')
    error('block is not an ssmblock object')
  end
  if ischar(data)
    data = {data};
  end
  
  if iscellstr(data)
    if numel(data) == 1 && strcmpi(data{1}, 'all')
      [blockNumber portNumber] = forAll(block);
    elseif numel(data) == 1 && strcmpi(data{1}, 'none')
      [blockNumber portNumber] = forNone();
    else
      [blockNumber portNumber] = fromNames(block, data);      
    end
  else
    display(data)
    error('parameter ''data'' is of wrong type')
  end
end

function [blockNumber portNumber] = forAll(block)
  nBlocks = numel(block) ;
  nPorts = block.Nports;
  nPortsTot = sum(nPorts);
  
  blockNumber = zeros(nPortsTot,1);
  portNumber = zeros(nPortsTot,1);
  
  k = 1;
  for i=1:nBlocks
    for j=1:nPorts(i)
      blockNumber(k) = i;
      portNumber(k) = j;
      k = k+1;
    end
  end
end

function [blockNumber portNumber] = forNone()
  blockNumber = zeros(1,0);
  portNumber = zeros(1,0);
end

function [blockNumber portNumber] = fromNames(block, data)  
  nBlocks = numel(block) ;
  nPorts = block.Nports;
  
  blockNumber = zeros(1,0);
  portNumber = zeros(1,0);
  portNames = block.portNames;
  
  for i=1:numel(data)
    [isin, pos] = posBlock(block, data{i});
    if isin
      % indexing full block
      blockNumber = [blockNumber ones(1,nPorts(pos))*pos];  %#ok<AGROW>
      portNumber  = [portNumber  1:nPorts(pos)];  %#ok<AGROW>
    else
      % looking for a port to index
      for ii = 1:nBlocks
        found = strcmpi(portNames{ii}, data{i});
        wasFound = sum(found)>0;
        if wasFound;
          blockNumber = [blockNumber ii]; %#ok<AGROW>
          portNumber  = [portNumber  find(found)];  %#ok<AGROW>
          break
        end
      end
      if ~wasFound
        display(['block or port '  data{i} ' was not found!'])
      end
    end
  end
end

