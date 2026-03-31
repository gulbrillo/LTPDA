% MINUS Implements subtraction operator for timespan objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Implements subtraction operator for timespan objects. Numeric and
% string operands are transparently handled converting them to time objects.
% Vector operands are handled accordingly to MATLAB conventions.
%
%
% CALL:        bs = as - val;
%              bs = as - time;
%
% INPUTS:      as: a timespan object
%              val:  time or time string or numeric value
%
% OUTPUTS:     bs: a timespan object
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'minus')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = minus(varargin)
    
  % Settings
  op       = 'minus';
  opname   = 'subtract';
  opsym    = '-';
    
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
    
    % Get values for the timespan objects
    [as, values] = processSetterValues(as, pls, rest, opname);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Do not support timespan +/- timespan
  if isempty(values) && numel(as) > 1
    error('### Sorry, no idea how to %s two timespan objects', opname);
  end
  
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
    
    bs(jj).startT = feval(op, bs(jj).startT, tt);
    bs(jj).endT = feval(op, bs(jj).endT, tt);
    
    if ~callerIsMethod
      plh = pls.pset(opname, values{jj});
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
  pl = plist({'subtract', 'The time to subtract to the start and end time of the timespan.'}, paramValue.DOUBLE_VALUE(0));
end
