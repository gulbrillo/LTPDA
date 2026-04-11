% MAKEPORTINDEX gives indexes of selected in a series of list in a cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAKEPORTINDEX gives a cell array of binary indexes
%
% CALL: varargout = makePortIndex(varargin)
%
%       makePortIndex(cellstr, embeddedplist)
%       makePortIndex(embeddedplist_selection, embeddedplist)
%       makePortIndex(cellstr, embeddedplist)
%       makePortIndex(char, embeddedplist)
%       makePortIndex('all', sizes)
%       makePortIndex('none', sizes)
%       makePortIndex('all', embeddedplist)
%       makePortIndex('none', embeddedplist)
%       makePortIndex(mixed_cell, sizes)
%       makePortIndex(mixed_cell, embeddedplist)
%
% INPUTS:
%       select - input index:
%                         - cellstr,
%                         - cell array including
%                                 - array indexes with doubles or logicals,
%                                 - 'ALL'/'NONE' to index all/no content,
%                                 - a str for one variable name only
%                                 - a cellstr for multiple variables
%                         - a str for one variable name only
%       names - embedded plist giving block position names, used in case of cellstr
%       sizes - vector giving block sizes, required in case of mixed cell
%               array
%       indexing
%
% OUTPUTS:
%       index_out - index for the cell array of logical arrays
%
% ***** There are no parameters *****
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = makePortIndex(varargin)
  
  error('this function is deprecated and replaced by makePortLogicalIndex');

  select = varargin{2};
  if isempty(select)
    index_out = from_cellstr({}, varargin{1});
  elseif iscellstr(select)
    index_out = from_cellstr(select, varargin{1});
  elseif isa(select, 'cell')
    index_out = from_mixed_cell(select, varargin{1});
  elseif isa(select,'char')
    index_out = from_char(select, varargin{1});
  elseif isa(select,'plist')
    index_out = from_plist(select, varargin{1});
  else
    error('parameter ''select'' is of wrong type')
  end
  varargout = {index_out};
end

function index_out = from_plist(select, sb)  %#ok<INUSD,STOUT>
  error('not implemented yet! - to do when GUI input plist is defined')
end

function index_out = from_cellstr(select, sb)
  if ~isa(sb,'ssmblock')
    error(['second argument ''sb'' is not a ssmblock but a ' class(sb)])
  end
  
  % detecting block sizes
  Nblocks = numel(sb);
  sizes = sb.Nports;
  
  % initializing output
  index_out = cell(1,Nblocks);
  for i=1:Nblocks
    index_out{i} = false(1, sizes(i));
  end
  
  % looking for names
  for i=1:numel(select)
    %looking for block names
    [isin, pos] = posBlock(sb, select{i});
    if isin
      index_out{pos} = true(size(index_out{pos}));
    else
      % otherwise looking for variable names
      for j=1:Nblocks
        [isin, pos] = posPort(sb(j).ports, select{i});
        if isin
          index_out{j}(pos) = true;
          break;
        end
      end
    end
  end
  
end

function index_out = from_char(select, argument2)
  
  % looking at second input if it is
  if ~(isa(argument2,'ssmblock') || isa(argument2,'double'))
    display(argument2)
    display(class(argument2))
    error('second argument ''sizes'' is not a ssmblock nor a double array')
  end
  
  
  if strcmpi(select, 'ALL')
    if isa(argument2,'ssmblock')
      Nblocks = numel(argument2);
      sizes = argument2.Nports;
    else
      sizes = argument2;
      Nblocks = numel(sizes);
    end
    index_out = cell(1, Nblocks);
    % index all positions
    for i=1:Nblocks
      index_out{i} = true(1,sizes(i));
    end
  elseif strcmpi(select, 'NONE')
    if isa(argument2,'ssmblock')
      Nblocks = numel(argument2);
      sizes = argument2.Nports;
    else
      sizes = argument2;
      Nblocks = numel(sizes);
    end
    index_out = cell(1, Nblocks);
    % index all positions
    for i=1:Nblocks
      index_out{i} = false(1,sizes(i));
    end
  else
    if isa(argument2,'ssmblock')
      %     warning('adding ''{'' ''}'' around variable name for indexing'); %#ok<*WNTAG>
      index_out = from_cellstr({select}, argument2);
    else
      warning('error in the call index_out(char, embeddedplist) because the plist is not a plist');
    end
  end
  
end

function index_out = from_mixed_cell(select, argument2)
  if isa(argument2,'ssmblock')
    % detecting block sizes
    Nblocks = numel(argument2);
    sizes = argument2.Nports;
    forbidchar = false;
  else
    sizes = argument2;
    Nblocks = numel(sizes);
    forbidchar = true;
  end
  
  index_out = cell(1,Nblocks);
  % going through blocks
  for i=1:Nblocks
    if iscellstr(select{i}) % variable names indexing
      if forbidchar
        error('trying to index using variable names without variable name information')
      end
      index_out{i} = false(1,sizes(i));
      for j=1:sizes(i)
        index_out{i}(j) = (sum(strcmpi(argument2(i).ports(j).name, select{i}))>0);
      end
    elseif isa(select{i}, 'char')
      if strcmpi(select{i}, 'ALL') % keyword indexing
        index_out{i} = true(1, sizes(i));
      elseif strcmpi(select{i}, 'none') % keyword indexing
        index_out{i} = false(1, sizes(i));
      else % variable names indexing
        if forbidchar
          error('trying to index using variable names without variable name information')
        end
        index_out{i} = false(1,sizes(i));
        for j=1:sizes(i)
          index_out{i}(j) = (sum(strcmpi(argument2(i).ports(j).name, select{i}))>0);
        end
      end
    elseif isa(select{i},'double') % double indexing
      index_out{i} = false(1, sizes(i));
      for j=1:length(select{i})
        index_out{i}(select{i}(j))=true;
      end
    elseif isa(select{i},'logical') % logical indexing
      index_out{i} = select{i};
      if ~length(select{i})==sizes(i)
        error(['parameter ''select'' is of wrong size for block numer ', num2str(i)]);
      end
    else
      error('parameter ''select'' is of wrong type')
    end
  end
end

function [res, pos] = posPort(objs, name)
  %%%%%%%%%%   Some plausibility checks   %%%%%%%%%%
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
