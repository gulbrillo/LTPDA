% DIFF implements differentiation operator for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DIFF implements differentiation operator for smodel objects.
%
% CALL:        obj = diff(mdl, var)
%              obj = mdl.diff(var)
%              obj = mdl.diff(plist('var', var))
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'diff')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = diff(varargin)
  
  % Settings
  operatorName = 'diff';
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all smodels and plists
  [mdl, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pl, pl_invars, rest]      = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  if numel(mdl) ~= 1
    error('### diff only accepts one input smodel.');
  end
  
  % Decide on a deep copy or a modify
  dmdl = copy(mdl, nargout);
  
  % Combine input plists and default PLIST
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Select the variable to differentiate with respect to and the order:
  [var, n, pl] = utils.helper.process_smodel_diff_options(pl, rest);
  
  % Check the variable
  if isempty(var)
    var = mdl.xvar;
    if iscell(var)
      var = var{1};
    end
  end
  
  if isempty(var)
    error(['### Please specify a variable to differentiate with respect to, ' ...
      'or set the xvar properties of the model(s)!']);
  end
  
  % If the method was called by another method, we do not need to set history.
  % As such, the info object can be empty
  if callerIsMethod
    infoObj = [];
  else
    infoObj = getInfo('None');
  end
  
  % Apply the method to the model
  dmdl.sop(callerIsMethod, smodel_invars, operatorName, {var, n}, pl, infoObj);
  
  % Set units
  if strcmp(var, mdl.xvar)
    setYunits(dmdl, dmdl.yunits ./ dmdl.xunits);
  end

  % Set output
  varargout{1} = dmdl;

end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
  ii.setArgsmin(1);
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
  
  % Var
  p = param({'var', ['Variable to differentiate with respect to.<br>' ...
    'If left empty, the x variable of the model(s) will be used']}, paramValue.STRING_VALUE(''));
  pl.append(p);
  
  % n
  p = param({'n', 'Order of differentiation'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);
end


