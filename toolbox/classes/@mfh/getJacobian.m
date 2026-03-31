% GETJACOBIAN calculate Jacobian matrix for a given function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GETJACOBIAN calculate Jacobian matrix for a given function. Each function
%             is assumed to be function only of the parameters resepect to
%             which the derivative should be calculated. All the other
%             quantities should be inserted in the 'constants' field.
%
% CALL:                    J = getJacobian(func,pl)
%
% INPUTS:
%         - func. The function
%
% PARAMETERS:
%         - p0. The set of parameters. (double vector).
%         - DerivStep. The set of derivative steps. (doble vactor).
%
% OUTPUTS:
%         - J. the Jacobian matrix. n x q where q is numel(p0) and n is
%           numel(func(p0).y).
%
% ALGORITHM:
%
% For each parameter an incremented parameter is calculated as
%
% pd = p0
% pd(i) = DerivStep(i)*p0(i) + p0(i)
%
% if p0(i) = 0 then pd(i) = DerivStep(i) + p0(i).
%
% Then the function is evaluated
%
% f0 = func(p0)
% fd = func(pd)
%
% J = (fd - f0)./(pd(i) - p0(i))
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'getJacobian')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = getJacobian(varargin)
  
  % Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Use the caller is method flag
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    % Assume paramCovMat(sys, ..., ...)
    %Define inputs
    narginchk(3, 3);
    f         = varargin{1};
    theta     = varargin{2};
    DerivStep = varargin{3};
    
  else
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Assume loglikelihood(sys, plist)
    [mfh_in, mfh_invars] = utils.helper.collect_objects(varargin(:), 'mfh',   in_names);
    pl                   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
    % Combine plists
    pl = applyDefaults(getDefaultPlist, pl);
  
    % copy input mfh model
    f = copy(mfh_in,1);
    
    theta     = find_core(pl, 'pars');
    DerivStep = find_core(pl, 'DerivStep');
  
  end
  
  % create function handle
  fh_str = f.function_handle();
  
  % declare objects locally
  declare_objects(f);
  
  % create function handle
  func = eval(fh_str);
  
  % make double the parameter steps
  dStep = double(DerivStep);
  
  % evaluate function at p0
  y0 = func(theta);
  if isa(y0,'ao')
    y0 = y0.y;
  end
  
  % for the following math, we need the numeric values of the parameters
  ntheta    = double(theta);
  numParams = numel(ntheta);  
  J         = zeros(numel(y0), numParams);
  deltaP    = zeros(size(ntheta));
  
  for ii=1:numParams
    deltaP(ii) = abs(dStep(ii)*ntheta(ii));
    if deltaP(ii) == 0
      deltaP(ii) = abs(dStep(ii));
      if deltaP(ii) == 0
        deltaP(ii) = eps;
      end
    end
    
    % add step
    thetaNew = ntheta + deltaP;
    
    % evaluate function
    if isnumeric(theta)
      pnew = thetaNew;
    else
      pnew = theta.setY(thetaNew);
    end
    yd   = func(pnew);
    yd   = double(yd);    
    dy   = yd(:) - y0(:);
    
    J(:,ii) = dy./deltaP(ii);
    
    % reset deltaP
    deltaP(ii) = 0;
    
  end
  
  % create output object
  out = ao(J);
  
  % add history
  if ~callerIsMethod
    out.addHistory(getInfo('None'), pl, [], f.hist);
  end
  
  varargout = utils.helper.setoutputs(nargout, out);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist();

  p = param({'pars', 'The set of parameter values. A NumParams x 1 array or a pest object.'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'DerivStep', 'The set of derivative steps. A NumParams x 1 array'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

