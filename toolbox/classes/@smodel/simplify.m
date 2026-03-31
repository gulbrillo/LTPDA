% SIMPLIFY implements simplify operator for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFY implements simplify operator for smodel objects.
%
% CALL:        objs = simplify(mdls)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'simplify')">Parameters Description</a> 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplify(varargin)
  
  % Settings
  operatorName = 'simplify';
  
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
  
  % If the method was called by another method, we do not need to set history.
  % As such, the info object can be empty
  if callerIsMethod
    infoObj = [];
  else
    infoObj = getInfo('None');
  end
  
  % Apply the method to all models
  mdls.sop(callerIsMethod, smodel_invars, operatorName, {}, pl, infoObj);
  
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
  pl = plist.EMPTY_PLIST;
end


