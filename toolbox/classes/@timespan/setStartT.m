% SETSTARTT sets the 'startT' property of the timespan objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETSTARTT sets the 'startT' property of the timespan objects.
%
% CALL:        objs.setStartT(val);
%              objs.setStartT(val1, val2);
%              objs.setStartT(plist('startt', val));
%              objs = objs.setStartT(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  String or numeric values
%                 1. Single string e.g. '14:00:00'
%                      Each timespan object in objs get this value.
%                 2. Single string in a cell-array e.g. {12345}
%                      Each timespan object in objs get this value.
%                 3. cell-array with the same number of strings as in objs
%                    e.g. {'14:00:00', 123, '15:00:00'} and 3 timespan objects in objs
%                      Each timespan objects in objs get its corresponding
%                      value from the cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'setStartT')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setStartT(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    as     = varargin{1};
    values = varargin(2:end);
    
  else
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
    
    % Collect all timespan objects
    [as,  ts_invars, rest] = utils.helper.collect_objects(varargin(:), 'timespan', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 'startT';
    
    % Get values for the timespan objects
    [as, values] = processSetterValues(as, pls, rest, pName);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over timespan objects
  for jj = 1:numel(bs)
    
    %%% If the time is a string then convert the string into a time-object.
    tt = values{1};
    if ischar(tt)
      tt = time(tt);
    elseif isnumeric(tt)
      tt = time(tt);
    end
    
    bs(jj).startT = tt;
    if ~callerIsMethod
      plh = pls.pset(pName, values{jj});
      bs(jj).addHistory(getInfo('None'), plh, ts_invars(jj), bs(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'startT', 'Start time of the time span.'}, paramValue.EMPTY_STRING);
end
