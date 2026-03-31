% SPSDSUBTRACTION makes a sPSD-weighted least-square iterative fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPSDSUBTRACTION makes a sPSD-weighted least-square iterative fit
%
% CALL: [MPest, aoResiduum, plOut, aoP, aoPini] = optSubtraction(mat_Y, mat_U);
%       [MPest, aoResiduum, plOut, aoP, aoPini] = optSubtraction(mat_Y, mat_U, pl);
%
%  The function finds the optimal M that minimizes the sum of the weighted sPSD of
%  (mat_Y - M * mat_U)
%
%  OUTPUTS: - MPest: output PEST object with parameter estimates
%           - aoResiduum: residuum times series
%           - plOut: plist containing data like the parameter estimates
%           - aoP: last weight used in the optimization (fater last
%             Maximization/Expectation step)
%           - aoPini: initial weight used in the optimization (before first
%             Maximization/Expectation step)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'optSubtraction')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spsdSubtraction(varargin)
  
  % use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  if ~nargin>1
    error('optSubtraction requires at two input matrix objects (less than two input arguments were provided!)')
  end
  
  %% retrieving the two input aos
  [mat_in, mat_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  
  if numel(mat_in)~=2
    error('first two inputs should be two matrices of aos involved in the subtraction')
  end
  
  % Collect plist
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pl);
  
  %% getting ao arrays
  ao_Y = mat_in(1).objs;
  ao_U = mat_in(2).objs;
  
  %% running the ao method
  if nargout>2
    [MPest, plOut, aoResiduum, aoP, aoPini] = optSubtraction(ao_Y, ao_U, pl);
    matResiduum = matrix(aoResiduum);
    matP        = matrix(aoP);
    matPini     = matrix(aoPini);
  else
    [MPest, plOut] = optSubtraction(ao_Y, ao_U, pl);
  end
  
  %% collecting history
  if callerIsMethod
    % we don't need the history of the input
  else
    inhist  = mat_in(:).hist;
  end
  
  %% adding history
  if callerIsMethod
    % we don't to set the history
  else
    MPest.addHistory(getInfo('None'), pl, mat_invars, inhist);
    if nargout>2
      matP.addHistory(getInfo('None'), pl, mat_invars, inhist);
      matPini.addHistory(getInfo('None'), pl, mat_invars, inhist);
      matResiduum.addHistory(getInfo('None'), pl, mat_invars, inhist);
    end
  end
  
  %% return coefficients and hessian and Jfinal and powAvgWeight
  varargout = {MPest, plOut, aoP, aoPini};
  
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
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = ao.getInfo(mfilename(), 'Default').plists;
end


