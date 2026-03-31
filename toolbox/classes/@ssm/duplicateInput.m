% DUPLICATEINPUT copies the specified input blocks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DUPLICATEINPUT copies the specified input blocks.
%
% CALL:        obj = obj.duplicateInput( blockIndex, newBlockNames);
%              obj = obj.duplicateInput( blockNames, newBlockNames);
%
%  blockname may be a double, a string or a cellstr 
%  newBlockNames may be a string or a cellstr
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'duplicateInput')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = duplicateInput(varargin)
  
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
  blockIds  = pl.find('blocks');
  newNames = pl.find('names');
  
  if ischar(newNames)
    newNames = {newNames};
  end
  if ischar(blockIds)
    blockIds = {blockIds};
  end
  
  %% Some error checking....
  if numel(newNames) ~= numel(blockIds)
    error('### Please specify one new name per block');
  end
  
  %% Loop over the input ssm objects
  for kk = 1:numel(sys)
    blocks0 = sys(kk).inputs;
    % collecting the blocks indexes
    if isnumeric(blockIds)
      positions = blockIds;
    else
      positions = zeros(1,0);
      for ii=1:numel(blockIds)
        [pos2, res2] = findBlockWithNames(blocks0, newNames{ii}, false); 
        if res2
          warning('### input blocks ''%s'' already exists in SSM model ''%s'', duplication of ''%s'' is impossible', newNames{ii}, sys(kk).name, blockIds{ii});  
          beep;
        else
          [pos, res] = findBlockWithNames(blocks0, blockIds{ii});
          if res
            positions = [positions pos]; %#ok<AGROW>
          else
            warning('### input blocks ''%s'' not found in SSM model ''%s'' ', blockIds{ii}, sys(kk).name);
          end
        end
      end
    end
    
    %% now copying input    
    Ni = sys(kk).Ninputs;
    sys(kk).bmats = [sys(kk).bmats  sys(kk).bmats(:,positions) ];
    sys(kk).dmats = [sys(kk).dmats  sys(kk).dmats(:,positions) ];
    sys(kk).inputs = [sys(kk).inputs  copy(sys(kk).inputs(positions),true) ];
    
    for ii=1:numel(positions)
      sys(kk).inputs(Ni+ii).setBlockNames(newNames{ii});
    end

    % append history step
    if ~internal
      sys(kk).addHistory(getInfo('None'), pl, ssm_invars(kk), sys(kk).hist);
    end
  end % End loop over blocks
  
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
  
  % blocks
  p = param({'blocks', 'Identifiers (strings or indices) of the input blocks you want to copy.'}, paramValue.EMPTY_STRING);
  plo.append(p);
  
  % names
  p = param({'names', 'The new name(s) you want to set to the new inputs. Use a cell-array, one entry for each of them.'}, ...
    paramValue.EMPTY_STRING);
  plo.append(p);
  
end

