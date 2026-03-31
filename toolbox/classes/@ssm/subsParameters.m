% SUBSPARAMETERS enables to substitute symbolic patameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBSPARAMETERS enables to modify and substitute parameters
%
% CALL: varargout = subsParameters(varargin)
%       [sys_out] = subsParameters(sys_out, options)
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'subsParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = subsParameters(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    % assume call is subsParameters(sys, pl)
    % or subsParameters(sys)
    sys = varargin{1};
    if nargin == 2
      pl  = varargin{2};
    else
      pl = plist('names', 'all');
    end
  else    
    % Collect input variable names
    in_names = cell(size(varargin));
    for ii = 1:nargin, in_names{ii} = inputname(ii); end
    
    % Collect all SSMs and options
    [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
    % Get plist
    pl = applyDefaults(getDefaultPlist, varargin{:});
  end
  
  
  % processing input
  subsnames = pl.find('names');
  if ischar(subsnames)
    subsnames = {subsnames};
  elseif ~iscellstr(subsnames)
    error('param names be a cellstr')
  end
  
  % Support single 'all' key.
  if numel(subsnames) == 1 && strcmpi(subsnames{1}, 'all')
    % get all parameter names of this model
    subsnames = sys.params.getKeys;
  end
  
  % Decide on a deep copy or a modify, depending on the output
  sys_out = copy(sys, nargout);
  Nsys = numel(sys);
  
  for i_sys = 1:Nsys
    sys_out(i_sys).doSubsParameters(subsnames, callerIsMethod);
    if ~callerIsMethod
      sys_out(i_sys).addHistory(getInfo('None'), pl, ssm_invars(i_sys), sys_out(i_sys).hist );
    end
  end
  
  % Set output
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  pl = plist();  
  p = param({'names', 'A cell-array of parameter names for substitution. A value of ''all'' will result in all parameters being substituted by their numerical values.'}, {'All'});
  pl.append(p);
end

