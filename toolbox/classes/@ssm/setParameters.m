% SETPARAMETERS Sets the values of the given parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPARAMETERS Sets the values of the given parameters.
%
% CALL:        obj = obj.setParameters(plist);
%                    obj.setParameters(name1, val1, name2, val2, ...)
%                    obj.setParameters({name1, name2}, [val1 val2 ...])
%                    obj.setParameters(pest)
% 
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'setParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setParameters(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin, in_names{ii} = inputname(ii); end
  
  % Collect all SSMs and options
  [sys, ssm_invars, rest]  = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, ~, rest]  = utils.helper.collect_objects(rest(:), 'plist');

  if ~callerIsMethod
    pl = applyDefaults(getDefaultPlist(), pl);
  end
  
  setnames = {};
  setvalues = [];
  pestHistory = [];
  % Check if 'rest' contains a pest object, if so, get the names and values
  % from there and put the pest in the history.
  for kk=1:numel(rest)
    if isa(rest{kk}, 'pest')
      p = rest{kk};
      setnames  = p.names;
      setvalues = p.y;
      pestHistory = p.hist;
      break
    end
  end
  
  % processing input
  if isempty(setnames)
    setnames = pl.find('names');
    if ischar(setnames)
      setnames = {setnames};
    elseif ~iscellstr(setnames)
      error('### Parameter names must be a cell-array of strings')
    end
  end
  
  if isempty(setvalues)
    setvalues = pl.find('values');
    if ~isa(setvalues, 'double')
      error('### param values should be a double')
    end
  end
  
  if isempty(setnames)
    % try to get from the 'rest' inputs
    if numel(rest) == 2
      % cell-array, value_array
      
      if ~isnumeric(rest{2})
        error('Please provide numeric values for the parameters');
      end
      
      if ~iscell(rest{1})
        setnames = {rest{1}};
      else
        setnames = rest{1};
      end
      
      setvalues = rest{2};      
      
    else
      
      % name, value pairs
      setnames  = rest(1:2:end);
      setvalues = [rest{2:2:end}];
      
    end
    
  end
  
  if isempty(setnames)
    error('Please provide at least one parameter name to set');
  end
    
  Nsys    = numel(sys);
  sys_out = copy(sys,nargout);
  
  % checking data
  Nset = length(setnames);
  if ~(Nset== length(setvalues))
    error(['### The number of parameter names is ' num2str(Nset) ' and the number of parameter values is ' num2str(length(setvalues))]);
  end
  if ~isa(setvalues, 'double')
    error(['### Parameter ''values'' is not a double array but of class ' class(setvalues)]);
  end
  
  % proceeding parameters update
  for i_sys = 1:Nsys
    sys_out(i_sys).doSetParameters(setnames, setvalues);
    if ~callerIsMethod
      sys_out(i_sys).addHistory(getInfo('None'), plist('names',setnames, 'values', setvalues ), ssm_invars(i_sys), [sys_out(i_sys).hist pestHistory]);
    end
  end
  
  % Set outputs
  varargout = utils.helper.setoutputs(nargout, sys_out);
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();
  
  p = param({'names', 'A cell-array of parameter names for numerical substitutions.'}, {});
  pl.append(p);
  
  p = param({'values', 'An array of parameter values for numerical substitutions.'}, []);
  pl.append(p);
end
