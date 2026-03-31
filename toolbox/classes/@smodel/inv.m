% INV evaluates the inverse of smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INV evaluates the inverse of smodel objects
%
% CALL:        mdl = inv(mdl)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'inv')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = inv(varargin)
  
  % Settings
  operatorName   = 'inv';
  
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
  pl        = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Decide  on a deep copy or a modify
  mdls = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Apply the operator
  mdls.op(operatorName);
 
  if ~callerIsMethod
    % Add history
    mdls.addHistory(getInfo('None'), pl, smodel_invars, [mdls(:).hist]);
    
    % Set name
    mdls.name   = [operatorName '(' mdls.name ')'];
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
  pl = plist.EMPTY_PLIST;
end
