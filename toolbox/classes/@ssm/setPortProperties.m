% SETPORTPROPERTIES Sets names of the specified SSM ports.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPORTPROPERTIES Sets names of the specified SSM ports.
%
% CALL:        obj = obj.setPortProperties(plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'setPortProperties')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPortProperties(varargin)
  
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
  
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  if ~isempty(rest)
    pl = combine(pl, plist(rest{:}));
  end
  pl = combine(pl, getDefaultPlist());
  
  %%% Internal call: Only one object + don't look for a plist
  internal = utils.helper.callerIsMethod();
  
  sys = copy(sys, nargout);
  
  %% parameters
  
  field    = pl.find('field');
  portIds  = pl.find('ports');
  newNames = pl.find('NEW_NAMES');
  newDescriptions = pl.find('NEW_DESCRIPTIONS');
  newUnits = pl.find('NEW_UNITS');
  
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
    
    [blockPos portPos] = block.findPortWithMixedNames(portIds); 
    if ~isempty(newDescriptions)
      if numel(newDescriptions) ~= numel(blockPos)
        error('### Please specify one new description per block');
      end
      for ii=1:numel(blockPos)
        block(blockPos(ii)).ports(portPos(ii)).setDescription(newDescriptions(ii));
        % setting the new description
      end
    end
    if ~isempty(newNames)
      if numel(newNames) ~= numel(blockPos)
        error('### Please specify one new description per block');
      end
      for ii=1:numel(blockPos)
        block(blockPos(ii)).ports(portPos(ii)).setName( newNames(ii), block(blockPos(ii)).name);
        % setting port name. This call only modifies the blockName.portName
        % part after the dot. The user shouldn't be able to do otherwise.
      end
    end
    if ~isempty(newUnits)
      if numel(newUnits) ~= numel(blockPos)
        error('### Please specify one new description per block');
      end
      for ii=1:numel(blockPos)
        block(blockPos(ii)).ports(portPos(ii)).setUnits(newUnits(ii));
        % setting units
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist();
  
  % field
  p = param({'field', 'The field containing the port being changed.'}, {1, {'inputs', 'outputs', 'states'}, paramValue.SINGLE});
  plo.append(p);
  
  % ports
  p = param({'ports', 'Identifiers  (cellstr of "blockNames"/"blockNames.portNames" or "ALL")  of the ports you want to modify.'},  paramValue.EMPTY_CELL );
  plo.append(p);
  
  % names
  p = param({'NEW_NAMES', 'The new names(s) you want to set to the port(s). Use a cell-array, one entry for each port.'}, ...
    paramValue.EMPTY_CELL );
  plo.append(p);
  
  % descriptions
  p = param({'NEW_DESCRIPTIONS', 'The new descriptions(s) you want to set to the port(s). Use a cell-array, one entry for each port.'}, ...
    paramValue.EMPTY_CELL );
  plo.append(p);
  
  % units
  p = param({'NEW_UNITS', 'The new names(s) you want to set to the port(s). Use a unit vector, one entry for each port.'}, ...
    {1, {unit.initObjectWithSize(1,0) }, paramValue.OPTIONAL});
  plo.append(p);
  
end


