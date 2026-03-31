% SETXVALS sets the 'xvals' property of the underlying smodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETXVALS sets the 'xvals' property of the underlying smodel object.
%
% CALL:        objs.setXvals(val);
%              objs.setXvals(plist('xvals', val));
%              objs = objs.setXvals(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  Val can be any of the following types:
%                     - double-vector
%                     - analysis object(s)
%                     - plist with the key 'xvals'
%                     - cell array with the value above
%                    All objects in 'objs' get 'val' as the 'xvals'
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setXvals')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXvals(varargin)
  
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
  
  % Collect all smodel objects
  [sm,  sm_invars, rest] = utils.helper.collect_objects(varargin(:), 'pest', in_names);
  [pls, dummy, onlyAoRest] = utils.helper.collect_objects(rest(:), 'plist');
  [aos, dummy, onlyAoRest] = utils.helper.collect_objects(onlyAoRest(:), 'ao');
  
  values  = {};
  inhists = [];
  % If pls contains only one plist with the single key of the property name
  % then set the property with a plist.
  
  % Combine input plists and default PLIST
  pls = applyDefaults(getDefaultPlist(), pls);
  
  % Special behaviour for the history if the user uses only AOs for the xvals
  if ~isempty(aos) && isempty(onlyAoRest)
    inhists = [aos(:).hist];
    values = processValues(values, pls, aos);
  else
    values = processValues(values, pls, rest);
  end
  
  % Check if the x-values are empty
  if isempty(values)
    error('### Please specify at least one input for ''xvals''');
  end
  % Make sure that all x-values have the same length
  if any(diff(cellfun(@length, values)) ~= 0)
    error('### The xvals must have the same length. But they have the length %s', mat2str(cellfun(@length, values)));
  end
  
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over pest objects
  for jj = 1:numel(sm)
    
    for kk=1:numel(sm(jj).models)
      mdl = sm(jj).models(kk);
      mdl.setXvals(values);
    end
    
    if isempty(inhists)
      % Add the values only to the history-plist if the user doesn't use
      % AOs for the xvals.
      plh = pls.pset('xvals', values);
    else
      plh = pls;
    end
    sm(jj).addHistory(getInfo('None'), plh, sm_invars(jj), [sm(jj).hist, inhists]);
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, sm);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function values = processValues(values, dpl, rest)
  
  if ~isempty(rest)
    switch class(rest)
      case 'cell'
        for ii = 1:numel(rest);
          values = processValues(values, dpl, rest{ii});
        end
      case 'double'
        values = [values {rest}];
      case 'ao'
        ax = dpl.find_core('axis');
        for ii = 1:numel(rest)
          values = [values {rest(ii).(ax)}];
        end
      case 'plist'
        if length(rest) == 1 && isa(rest, 'plist') && isparam_core(rest, 'xvals')
          vals = find_core(rest, 'xvals');
          values = processValues(values, dpl, vals);
        end
      otherwise
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  pl = plist();
  
  % xvals
  p = param({'xvals', 'A vector of values for the X variables.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % axis
  p = param({'axis', 'Chose the axis where to take the data from the ao.'}, {1, {'y', 'x', 'z'}, paramValue.OPTIONAL});
  pl.append(p);
  
end
