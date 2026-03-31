% SETBLOCKPROPERTIES Sets the specified properties of the specified SSM blocks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETBLOCKPROPERTIES Sets properties of the specified SSM blocks.
%
% CALL:        obj = obj.setBlockProtperties(...
%                'FIELD', 'inputs', 'BLOCKS', 'ALL', ... % or a cellstr to indicate the blocks
%                'NEW_NAMES', {'names'...}, 'NEW_DESCRIPTIONS');
%
%  blockname may be a double, a string or a cell-array of strings of size 1
%  newBlockDescription may be a string or a cell-array of strings
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'setBlockProperties')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setBlockProperties(varargin)
  
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
  
  [ssms, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %%% Internal call: Only one object + don't look for a plist
  internal = utils.helper.callerIsMethod();
  
  sys = copy(ssms, nargout);
  
  %% parameters
  
  field    = pl.find('field');
  blockIds = pl.find('blocks');
  newDescriptions = pl.find('NEW_DESCRIPTIONS');
  newNames = pl.find('NEW_NAMES');
  
  if ischar(newDescriptions)
    newDescriptions = {newDescriptions};
  end
  if ischar(newNames)
    newNames = {newNames};
  end
    
  % Some error checking....
  if isempty(field)
    error('### Please specify the field of the block to modify');
  end
  
  %% Loop over the input ssm objects
  for kk = 1:numel(sys)
    block = sys(kk).(field);
    
    [pos, logic] = block.findBlockWithNames(blockIds, 'do warning');    
    if ~isempty(newDescriptions)
      if numel(newDescriptions) ~= numel(pos)
        error('### Please specify one new description per block');
      end
      for ii=1:numel(pos)
        block(pos(ii)).setBlockDescriptions(newDescriptions{ii});
      end
    end
    if ~isempty(newNames)
      if numel(newNames) ~= numel(pos)
        error('### Please specify one new description per block');
      end
      for ii=1:numel(pos)
        block(pos(ii)).setBlockNames(newNames{ii});
      end
    end
    if ~internal
      % append history step
      sys(kk).addHistory(getInfo('None'), pl, ssm_invars(kk), sys(kk).hist);
    end
  end % End loop over block IDs
  
  %% Set output
  if nargout == numel(sys)
    for ii = 1:numel(sys)
      varargout{ii} = sys(ii);
    end
  else
    varargout{1} = sys;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function plo = getDefaultPlist()
  plo = plist();
  
  % type
  p = param({'field', 'The field being changed'}, {1, {'inputs', 'outputs', 'states'}, paramValue.SINGLE});
  plo.append(p);
  
  % blocks
  p = param({'BLOCKS', 'Identifiers (cellstr of block names or "ALL") of the blocks you want to modify'}, paramValue.EMPTY_CELL);
  plo.append(p);
  
  % descriptions
  p = param({'new_descriptions', 'The new description(s) you want to set to the block(s). Use a cell-array, one entry for each block.'}, ...
    paramValue.EMPTY_CELL);
  plo.append(p);
  
  % names
  p = param({'new_names', 'The new names(s) you want to set to the block(s). Use a cell-array, one entry for each block.'}, ...
    paramValue.EMPTY_CELL);
  plo.append(p);
  
end

