% SSMBLOCK a helper class for the SSM class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SSMBLOCK a helper class for the SSM class.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%   sb = ssmblock(name);
%   sb = ssmblock(name, ports);
%   sb = ssmblock(name, ports, desc);
%
% SEE ALSO: ltpda_obj, ltpda_nuo, ssm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ssmblock < ltpda_nuo
  
  % -------- Public (read/write) Properties  -------
  properties
  end % -------- Public (read/write) Properties  -------
  
  % -------- Private read-only Properties --------
  properties (SetAccess = protected)
    name        = ''; % name of the block
    ports       =  ssmport.initObjectWithSize(1,0); % empty array of SSMPort objects
    description = ''; % description of the block
  end % -------- Private read-only Properties --------
  
  % -------- Dependant Properties ---------
  properties (Dependent)
    
  end  %-------- Dependant Hidden Properties ---------
  
  % -------- constructor ------
  methods
    
    function sb = ssmblock(varargin)
      switch nargin
        case 0
          % Empty constructor
        case 1
          if isstruct(varargin{1})
            % from struct
            sb = fromStruct(sb, varargin{1});
          elseif isa(varargin{1}, 'ssmblock')
            % copy constructor
            sb = copy(varargin{1},1);
          else
            error('### Unknown single argument constructor: ssmblock(%s)', class(varargin{1}));
          end
        case 2
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            sb = fromDom(sb, varargin{1}, varargin{2});
          else
            error('### Unknown two argument constructor: ssmblock(%s, %s)', class(varargin{1}), class(varargin{2}));
          end
        otherwise
          error('### Unknown argument constructor');
      end
    end % -------- constructor ------
    
  end   % -------- constructor methods ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods(Access = public, Hidden = true)
    
    varargout = tohtml(varargin)
    
    function clearAllUnits(inputs)
      for kk=1:numel(inputs)
        inputs(kk).ports.clearAllUnits;
      end
    end
    
    % counting methods for ssmblock arrays
    % these methods are for a whole array object, therefore cannot be
    % implemented as class methods
    function Nblocks = Nblocks(block)
      Nblocks = numel(block);
    end
    
    function Nports = Nports(block)
      Nports = zeros(1, numel(block));
      for i=1:numel(block)
        Nports(i) = numel(block(i).ports);
      end
    end
    
    % "properties" methods for ssmblock arrays
    % these methods are for a whole array object, therefore cannot be
    % implemented as class methods
    function blocknames = blockNames(block)
      blocknames = cell(1, numel(block));
      for i=1:numel(block)
        blocknames{i} = block(i).name;
      end
    end
    
    function blockDescriptions = blockDescriptions(block)
      blockDescriptions = cell(1, numel(block));
      for i=1:numel(block)
        blockDescriptions{i} = block(i).description;
      end
    end
    
    function ports = getPorts(varargin)
      warning('LTPDA:ssmblock', 'This function is outdated and will be deleted');
      ports = [];
      for kk=1:nargin
        if isa(varargin{kk}, 'ssmblock')
          for ll=1:numel(varargin{kk})
            ports = [ports varargin{kk}(ll).ports]; %#ok<AGROW>
          end
        end
      end
    end
    
    % "properties" methods for ssmblock.ports in ssmblock arrays
    % these methods are for a whole array object, therefore cannot be
    % implemented as class methods
    function portnames = portNames(block)
      portnames = cell(1, numel(block));
      for i=1:numel(block)
        portnames{i} = block(i).ports.portNames;
      end
    end
    
    function portDescriptions = portDescriptions(block)
      portDescriptions = cell(1, numel(block));
      for i=1:numel(block)
        portDescriptions{i} = block(i).ports.portDescriptions;
      end
    end
    
    function portUnits = portUnits(block)
      portUnits = cell(1, numel(block));
      for i=1:numel(block)
        portUnits{i} = block(i).ports.portUnits;
      end
    end
    
    % setting methods for ssmblock arrays
    function block = setBlockNames(block, blockNames)
      if ischar(blockNames), blockNames = {blockNames};  end
      % checking name format is correct
      for i=1:numel(block)
        blockName = blockNames{i};
        if numel(strfind(blockName,'.'))>0
          error('The "." is not allowed in ssmport name')
        end
        if numel(strfind(blockName,' '))>0
          error('The space " " is not allowed in ssmport name')
        end
        % modifying the port names so the prefix ("blockName.") is updated
        block(i).ports.modifyBlockName(block(i).name, upper(blockName));
        block(i).name = upper(blockName);
      end
    end
    
    function block = setBlockDescriptions(block, desc)
      if ischar(desc), desc = {desc};  end
      for i=1:numel(block)
        block(i).description = desc{i};
      end
    end
    
    function block = setPortsWithSize(block, size)
      for i=1:numel(block)
        block(i).ports = ssmport.initObjectWithSize(1, size(i));
      end
    end
    
    
    % setting methods for ssmblock.ports in ssmblock arrays
    function block = setPortDescriptions(block, portDesc)
      for i=1:numel(block)
        block(i).ports.setDescription(portDesc{i});
      end
    end
    
    function block = setPortUnits(block, portUnits)
      for i=1:numel(block)
        block(i).ports.setUnits(portUnits{i});
      end
    end
    
    %     function block = setPortNames(block, portNames, blockName)
    function block = setPortNames(block, portNames)
      for i=1:numel(block)
        %         block(i).ports.setName(portNames{i}, blockName{i});
        block(i).ports.setName(portNames{i}, block(i).name);
      end
    end
    
    % searching functions
    
    % searching ssmblock with Block names
    function [pos, logic] = findBlockWithNames(varargin)
      block = varargin{1};
      names = varargin{2};
      if nargin == 2
        doWarningMSG = true;
      elseif nargin == 3
        doWarningMSG = varargin{3};
      else
        error('### unknown call')
      end
      % returns position of names found in ssmblock
      if ischar(names), names = {names};  end
      pos = zeros(1, numel(names));
      logic = false(1, numel(names));
      blockNames = block.blockNames;
      for i=1:numel(names)
        logic_i = strcmpi(blockNames, names{i});
        if sum(logic_i)>0;
          pos(i) = find(logic_i,1);
          logic(i) = true;
        else
          % the case where "blockname" was not found
          if doWarningMSG
            display(['### No matching block was found for ' names{i} ' !!!'] )
          end
        end
      end
      % removing position for not-found entries
      pos = pos(logic);
    end
    
    % searching Ports with Port and Block names
    function [blockPos portPos logic] = findPortWithMixedNames(block, names)
      % takes as an input:
      % 'ALL' / 'NONE' / cellstr(blockNames || blockName.portNames)
      % returns : position of port/block, and a logical array telling if
      % the name was found
      if ischar(names)
        if strcmpi(names, 'ALL')
          % case 'ALL'
          logic = true;
          blockPos = zeros(1, 0);
          portPos = zeros(1, 0);
          Nports = block.Nports;
          for i=1:numel(block)
            blockPos = [blockPos ones(1,Nports(i))*i]; %#ok<AGROW>
            portPos  = [portPos  1:Nports(i)]; %#ok<AGROW>
          end
          return
        elseif strcmpi(names, 'NONE')
          % case 'NONE'
          logic = true;
          blockPos = zeros(1, 0);
          portPos = zeros(1, 0);
          return
        else
          % case 'portName' or  'blockName' with an input string
          names = {names};
        end
      end
      % case 'portName' or  'blockName'
      logic = false(1, numel(names));
      blockPos = zeros(1, 0);
      portPos = zeros(1, 0);
      portNames = block.portNames;
      blockNames = block.blockNames;
      Nports = block.Nports;
      for i=1:numel(names)
        found = strcmpi(blockNames, names{i});
        if sum(found)>0;
          % case where the "blockName" is provided
          position = find(strcmpi(blockNames, names{i}), 1);
          blockPos = [blockPos ones(1,Nports(position))*position]; %#ok<AGROW>
          portPos  = [portPos  1:Nports(position)]; %#ok<AGROW>
          logic(i) = true;
        else
          % case where a "(*)portname" is provided
          blockName = ssmblock.splitName(names{i});
          % case where the "blockName.portname" is provided
          posBlock = findBlockWithNames(block, blockName, false);
          if ~posBlock == 0
            for j=posBlock
              posPortLogic = strcmpi(portNames{j}, names{i});
              if sum(posPortLogic)>0;
                blockPos = [blockPos,  j]; %#ok<AGROW>
                portPos  = [portPos find(posPortLogic, 1)]; %#ok<AGROW>
                logic(i) = true;
                break;
              end
            end
          end
          % the case where no (*).portname / blockname was found
          if ~logic(i)
            % possibility where the block name is not matching between port and block
            for jj=1:numel(blockNames)
              posPortLogic = strcmpi(portNames{jj}, names{i});
              if sum(posPortLogic)>0;
                blockPos = [blockPos,  jj]; %#ok<AGROW>
                portPos  = [portPos find(posPortLogic, 1)]; %#ok<AGROW>
                logic(i) = true;
                break;
              end
            end
          end
          if ~logic(i)
            display(['### No matching block/port was found for key "' names{i} '" !!!'] )
          end
        end
      end
      blockPos = blockPos(blockPos>0);
      portPos  = portPos(portPos>0);
    end
    
    % searching Block Names with a given Block
    function index = makeBlockLogicalIndex(block, names)
      % returns a binary index for the  ssmblock
      if ischar(names), names = {names};  end
      blockNames = block.blockNames;
      index = false(1, numel(block));
      for i=1:numel(names)
        found = strcmpi(blockNames, names{i});
        index = index + found;
      end
      index = index>0;
    end
    
    % searching in Mixed Names with a given Block/Ports
    function index = makePortLogicalIndex(block, names)
      % takes as an input:
      % 'ALL'/'NONE'/cellstr(portnames)/
      % cellstr(blockName.portnames)/ cellstr(blockName_portnames)
      % returns a binary index for the  ssmblock
      Nports = block.Nports;
      index = cell(1, numel(block));
      if ischar(names)
        if strcmpi(names, 'ALL')
          % case 'ALL'
          for i=1:numel(block)
            index{i} = true(1,Nports(i));
          end
          return
        elseif strcmpi(names, 'NONE')
          % case 'NONE'
          for i=1:numel(block)
            index{i} = false(1,Nports(i));
          end
          return
        else
          % case 'portName' or  'blockName'
          names = {names};
        end
      end
      if iscellstr(names)
        % case {'portName' or  'blockName'}
        [blockPos portPos] = findPortWithMixedNames(block, names);
        blockPos = blockPos(blockPos>0);
        portPos  = portPos(portPos>0);
        for i=1:numel(block)
          index{i} = false(1,Nports(i));
        end
        for i=1:numel(blockPos)
          index{blockPos(i)}(portPos(i)) = true;
        end
      else
        % case {{logical} or {double}}
        if ~numel(names)==numel(block)
          error('Number of logical/double does not match the number of blocks')
        end
        for i=1:numel(block)
          if isa(names{i},'logical')
            index{i} = names{i};
          elseif isa(names{i},'double')
            index{i} = false(1,Nports(i));
            index{i}(names{i}) = true(1, numel(names{i}));
            if max(names{i})>Nports(i)
              error(['index is too large for indexed field : ' num2str(max(names{i}))...
                ' instead of '  num2str(Nports(i)) ' for the block called ' block.blockNames{i}]);
            end
          else
            display(names)
            error(['input field names is not "ALL", "NONE", not a cellstr, nor a cell with logical/binaries '...
              'but instead it is of class ' class(names{i}) ' for the block called ' block.blockNames{i}])
          end
        end
      end
    end
    
    % indexing functions
    function varargout = applyBlockPositionIndex(block, pos)
      % selects blocks depending on a double array index, order is not modified
      block = copy(block, nargout);
      warning('LTPDA:ssmblock', 'this function was modified, check behavior is okay')
      index = false(1, numel(block));
      for i=1:numel(pos)
        index(pos(i)) =true;
      end
      varargout = {block(index)};
    end
    
    function varargout = applyPortPositionIndex(block, blockPos, portPos)
      % selects ports depending on a double array index. Order of blocks
      % and ports are not modified
      block = copy(block, nargout);
      Nports = block.Nports;
      index = cell(1, numel(block));
      for i=1:numel(block)
        index{i} = false(1,Nports(i));
      end
      for i=1:numel(blockPos)
        if ~blockPos(i)==0
          index{blockPos(i)}(portPos(i)) = true;
        end
      end
      for i=1:numel(block)
        block(i).ports = block(i).ports(index{i});
      end
      varargout = {block};
    end
    
    function varargout = applyBlockLogicalIndex(block, logic)
      % selects blocks depending on a double array index, order is not
      % modified
      block = copy(block, nargout);
      varargout = {block(logic)};
    end
    
    function varargout = applyPortLogicalIndex(block, logic)
      % selects ports depending on a double array index. Order of blocks
      % and ports are not modified
      block = copy(block, nargout);
      for i=1:numel(block)
        block(i).ports = block(i).ports(logic{i});
      end
      varargout = {block};
    end
    
    % older search  functions
    % simple block names search
    % deprecated and replaced by findBlockWithNames
    function [res, pos] = posBlock(varargin)
      error('this function is deprecated and replaced by findBlockWithNames');
      objs = varargin{1};
      name = varargin{2};
      if ~ischar(name)
        error('### The ''name'' must be a string but it is from the class %s.', class(name));
      end
      res = 0;
      pos = 0;
      for ii = 1:numel(objs)
        if strcmpi(objs(ii).name, name)
          res = 1;
          pos = ii;
          break
        end
      end
    end
    
    % logical port indexing using complex entries
    % deprecated and replaced by makePortLogicalIndex
    varargout = makePortIndex(varargin) % can be removed now
    
    % simple block names search
    % deprecated and replaced by findPortWithMixedNames
    [blockNumber portNumber] = findPorts(block, data) % can be removed now
    
    % older indexing functions
    % simple block names search
    % deprecated and replaced by applyPortLogicalIndex
    function varargout = blocksPrune(sb, id)
      error('this function is deprecated and replaced by applyPortLogicalIndex');
      % Check input objects
      if ~isa(sb, 'ssmblock')
        error('### The first input must be a ssmblock.');
      end
      if ~isa(id, 'cell')
        error('### The second input must be a cell array.')
      end
      % Decide on a deep copy or a modify
      sb = copy(sb, nargout);
      for ii=1:numel(sb)
        sb(ii).ports = sb(ii).ports(id{ii});
      end
      varargout{1} = sb;
    end
    
    function block2 = mergeBlocksWithPositionIndex(block, blockIndex, portIndex, blockName)
      % takes as an input indexes of a ssmblock array, and returns one
      % block with all the selected ports within
      [groupedBlockIndex, groupedPortIndex, groupSize, nGroups, globalPortIndex] = ssmblock.groupIndexes(blockIndex, portIndex);
      
      if numel(blockIndex)~=numel(portIndex)
        error('different lengths of indexes!')
      end
      nPorts = numel(blockIndex);
      block2 = ssmblock;
      if numel(strfind(blockName,'.'))>0
        error('The "." is not allowed in ssmport name')
      end
      if numel(strfind(blockName,' '))>0
        error('The space " " is not allowed in ssmport name')
      end
      block2.name  = upper(blockName);
      
      block2.ports = ssmport.initObjectWithSize(1,nPorts);
      for ii=1:nGroups
        block2.ports(globalPortIndex{ii}) = block(groupedBlockIndex(ii)).ports(groupedPortIndex{ii});
      end
    end
    
    function varargout = combine(varargin)
      objs = utils.helper.collect_objects(varargin(:), 'ssmblock');
      pos = findBlockWithNames(objs, objs.blockNames, false);
      keep = (pos == 1:numel(pos));
      varargout{1} = objs(keep);
    end
    
  end % -------- Declaration of Public Hidden methods --------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static, private)                    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static=true, Access=private)
  end % -------- Declaration of Private Static methods --------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static=true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ssmblock');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set);
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ssmblock.newarray([varargin{:}]);
    end
    
  end %% -------- Declaration of Public Static methods --------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static, hidden)                     %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods(Static = true, Hidden = true)
        
    % factory constructors
    function sb = makeBlocksWithSize(sizes, names)
      if ~isa(sizes,'double')
        error('### first argument must be a double');
      end
      if ischar(names)
        names = {names};
      elseif ~iscellstr(names)
        error('### second argument must be a char/cellstr');
      end
      Nsb = numel(sizes);
      sb = ssmblock.initObjectWithSize(1,Nsb);
      sb.setBlockNames(names);
      for ii=1:Nsb
        sb(ii).ports = ssmport.initObjectWithSize(1,sizes(ii));
        sb(ii).ports.setName('', sb(ii).name);
      end
    end
    
    function sb = makeBlocksWithData(names, descriptions, varnames, varunits, vardescriptions)
      if ~iscellstr(names)
        error('first argument must be a cellstr');
      end
      Nsb = numel(names);
      % checking which parameters to set
      setdescriptions     = Nsb == numel(descriptions);
      setvarnames         = Nsb == numel(varnames);
      setvarunits         = Nsb == numel(varunits);
      setvardescriptions  = Nsb == numel(vardescriptions);
      sb = ssmblock.initObjectWithSize(1,Nsb);
      for ii=1:Nsb
        if setdescriptions
          sb(ii).description = descriptions{ii};
        end
        if setvarnames||setvarunits||setvardescriptions
          % checking if ports can be initialized
          if setvarnames
            Nports = numel(varnames{ii});
          elseif setvarunits
            Nports = numel(varunits{ii});
          elseif setvardescriptions
            Nports = numel(vardescriptions{ii});
          else
            Nports = 0;
          end
          sb(ii).ports = ssmport.initObjectWithSize(1,Nports);
          % setting ports properties
          if setvarnames
            sb(ii).ports.setName(varnames{ii}, upper(names{ii}));
          end
          if setvarunits
            sb(ii).ports.setUnits(varunits{ii});
          end
          if setvardescriptions
            sb(ii).ports.setDescription(vardescriptions{ii});
          end
        end
        % setting name in the end so the port name prefixes are modified
        sb(ii).setBlockNames(names{ii});
      end
      
    end
    
    % index transformation for ssmports and blockMat in ssm/reshuffle,
    function [groupedBlockIndex, groupedPortIndex, groupSize, nGroups, globalPortIndex] = groupIndexes(blockIndex, portIndex)
      % groupedBlockIndex : block # (double array) (same block can be
      %   repeated, but never twice sided-by-side, Preserves the order
      %   provided by user)
      % groupedPortIndex : port # (cell array of doubles, Preserves the order
      %   provided by user)
      % groupSize : numel of each double in the cell array groupedPortIndex
      % nGroups : numel of the cell array
      % globalPortIndex : first index for each port if aill arrays are concatenated
      
      % detecting groups
      diffBlock = [[0 find(diff(blockIndex)~=0)]+1 numel(blockIndex)+1];
      if diffBlock(end)==1
        nGroups = 0;
      else
        nGroups = numel(diffBlock)-1;
      end
      % creating output index arrays
      groupedPortIndex = cell(1, nGroups);
      groupedBlockIndex = zeros(1, nGroups);
      groupSize = zeros(1, nGroups);
      for kk=1:nGroups
        groupedPortIndex{kk} = portIndex(diffBlock(kk):diffBlock(kk+1)-1);
        groupedBlockIndex(kk) = blockIndex(diffBlock(kk));
        groupSize(kk) = diffBlock(kk+1)-diffBlock(kk);
      end
      % final cumulative index
      globalPortIndex = cell(1, nGroups);
      sumGroupedSize = cumsum([1 groupSize]);
      for kk=1:nGroups
        globalPortIndex{kk} = sumGroupedSize(kk):(sumGroupedSize(kk+1)-1);
      end
    end
    
    
    % string support for names
    function [blockName, portName] = splitName(name)
      location = strfind(name, '.');
      if  numel(location)>0
        if numel(location)>1
          error('There were more than one dot in a name!')
        end
        blockName = name(1:(location-1));
        portName = name((location+1):end);
      else
        error(['Could not find the "." in the port named "' name '". ' ...
          'The indexing has changed! Please copy the portname with a "." as in "BLOCKNAME.portname".' ])
      end
    end
    
    function [blockName, portName, worked] = reSplitName(blockName, portName)
      warning('This function is deprecated and will be removed. Please report if it was found to be used')
      location = strfind(portName, '_');
      worked = numel(location)>0;
      if worked
        blockName = [blockName '_' portName(1:(location(1)-1))];
        portName = portName((location(1)+1):end);
      else
        blockName = '';
        portName = '';
      end
    end
    
  end %% -------- Declaration of Hidden Static methods --------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods(Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end   
  
end
