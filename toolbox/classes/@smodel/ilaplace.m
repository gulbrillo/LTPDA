% ILAPLACE implements continuous s-domain inverse Laplace transform for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ILAPLACE implements continuous s-domain inverse Laplace transform for smodel objects.
%
% CALL:        obj = ilaplace(mdl, ret_var)
%              obj = mdl.ilaplace(ret_var)
%              obj = mdl.ilaplace(in_var, ret_var) [Please note the order!]
%              obj = mdl.ilaplace(plist('ret_var', ret_var, 'in_var', in_var))
%              obj = mdl.ilaplace(pl)
%
% INPUTS:      mdl      - input smodels
%              ret_var  - a string with a variable name to transform into
%              in_var   - a string with a variable name to transform with respect to
%              pl       - input parameter list
%
% OUTPUTS:     obj  - output smodel(s)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'ilaplace')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ilaplace(varargin)
  
  % Settings
  operatorName = 'ilaplace';
  
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
  [as, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  mdls = copy(as, nargout);
  
  % Combine input plists and default PLIST
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Select the variable to transform with respect to:
  [in_var, ret_var, pl] = utils.helper.process_smodel_transf_options(pl, rest);
  
  % Check the independent variable
  if isempty(in_var)
    in_var = as.xvar;
  end
  
  if isempty(in_var)
    error(['### Please specify the independent variable to transform with respect to, ' ...
      'or set the xvar properties of the model(s)!']);
  end
  
  % If the method was called by another method, we do not need to set history.
  % As such, the info object can be empty
  if callerIsMethod
    infoObj = [];
  else
    infoObj = getInfo('None');
  end
  
  % Apply the method to all models
  mdls.sop(callerIsMethod, smodel_invars, operatorName, {in_var, ret_var}, pl, infoObj);
  
  % Set units
  if strcmp(in_var, as.xvar)
    setYunits(mdls, mdls.yunits .* mdls.xunits);
    setXunits(mdls, 1 ./ mdls.xunits);
  end
  
  % Set output
  varargout{1} = mdls;
  
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
  
  % Ret_Var
  p = param({'ret_var', 'Return variable, to transform into.'}, paramValue.STRING_VALUE('t'));
  pl.append(p);
  
  % In_Var
  p = param({'in_var', ['Independent variable, to transform with respect to.<br>' ...
    'If left empty, the x variable of the model(s) will be used']}, paramValue.STRING_VALUE(''));
  pl.append(p);
  
end
