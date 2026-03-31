% getFitErrors calculates fisher matrix approximation of fit parameters
% errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALL:     cov = getFitErrors(func,pl)
%
% INPUTS:
%         - func. The function handle. If you use 'jacobian' algorith, func
%         must be the fit function. If you use 'hessian' algorith, func
%         must be the cost function.
%
% PARAMETERS:
%         - pars. The set of parameters. (pest object).
%         - DerivStep. The set of derivative steps. (doble vactor).
%         - mse. Mean Square Error. (Chi^2). (double number).
%         - algo. Algorithm used to calculate the covariance matrix. Can be
%         'jacobian' and 'hessian'.
%         In case of 'jacobian' algorith, func must be the fit function
%         (model).
%         In case of 'hessian' algorith, func must be the cost function.
%         For the difference between fit function and cost function see the
%         remarks below.
%         - dy. errors on y measurements. If you input dy the function does
%         not compensates for mse.
%
% OUTPUTS:
%         - out. A pest obect with the error and covariance field filled
%         in.
%
% IMPORTANT REMARKS
%
% GENERAL REMARKS ON THE HESSIAN MATRIX AND ERROR CALCULATION.
%
% Care must be taken in definining the cost function from which we
% calculate the errors. The hessian matrix calculation is aiming to provide
% the curvature of the cost function around its maximum. The formalism is
% perfectly consistent in case of Gaussian assumption for which the inverse
% of the expected covariance (Fisher Information) is:
%
% F(i,j) = -E(dlLike / dxi dxj)   i,j = 1,...,n
%
% where E is the expectation value, lLike is the log Likelihood, xi and xj
% are parameters with i and j running over the parameters numbers.
% In the Gaussian assumption:
%
% lLike = -(1/2)*sum_k(((yk - f(x1,...,xn))/sk)^2) + const.
%
% Here yk are the data, xi the parameters, sk is the standard error on the
% data yk and f(x1,...,xn) is the fit function (model). As it is customary
% in least square fits, we minimize -2*lLike, i.e.
%
% SE(x1,...,xn) = sum_k(((yk - f(x1,...,xn))/sk)^2)
%
% Assuming SE is the cost function we have:
% 
% H(SE) = dSE / dxi dxj   i,j = 1,...,n
%
% where H is the Hessian matrix. Following the definition of F as the
% inverse of the expected covariance we have:
%
% C = 2*inv(H)
%
% Where C is the expected covariance matrix of the fit parameters.
% It is important to follow the definition given above in order to obtain a
% proper error. In case a cost function different from SE is used the
% result should be adapted accordingly.
%
% DIFFERENCE BETWEEN FIT FUNCTION AND COST FUNCTION
%
% Fit function is the fit model while cost function is the function
% minimized (maximized) in the fit. As an exaples in least squares fits
% with Gaussian assumption we have:
%
% cost function = sum_k(((yk - f(x1,...,xn))/sk)^2)
%
% fit function = f(x1,...,xn)
%
% Where yk are the data samples and xi are the fit parameters with
% i=1,...,n.
%
% COST FUNCTION AND MEAN SQUARED ERROR
%
% Mean Squared Error is the average of the squares of the fit residuals.
% The average is typically weighted for the fit parameters so following the
% definitions introduced above, the cost function or squared error is:
%
% SE(x1,...,xn) = sum_k(((yk - f(x1,...,xn))/sk)^2)
%
% While the MSE is:
%
% MSE = SE/(K-n)
%
% Where K is the number of data points and n is the number of parameters.
% MSE is used in error calculation to compensate for unknown data errors
% sk. In that case an average data error can be estimated with the MSE.
% That provides the correct estimation of the data error only if it is
% costant, in general instead it just provides a coefficient for error
% adjustment.
% In case you know data errors sk it is mandatory to:
% 1) Define the cost function including that information. i.e.
%    SE(x1,...,xn) = sum_k(((yk - f(x1,...,xn))/sk)^2)
% 2) Input sk vactor in the input field dy. In that case the function will
%    not compensate for MSE.
%
% If you use a cost function with no error information, i.e. 
% CF(x1,...,xn) = sum_k(((yk - f(x1,...,xn)))^2)
% then error are calculating assuming that your errors sk = 1 for each k.
% In that case it is a good practice at least to try to compensate for the
% MSE.
%
% COST FUNCTION DEFINITION
%
% Never use an averaged cost function if you want to calculate the errors
% with the Hessian option. An example of non-averaged cost function is the
% squared error defined above:
%
% SE(x1,...,xn) = sum_k(((yk - f(x1,...,xn))/sk)^2)
%
% Its averaged version is the MSE
%
% MSE = SE/(K-n)
%
% In oder to have a meaningful error estimate with the Hessian option the
% input 'func' must be the non-averaged one, i.e. SE.
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'getFitErrors')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = getFitErrors(varargin)
  
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
    narginchk(4, 6);
    f         = varargin{1};
    pars        = varargin{2};
    DerivStep = varargin{3};
    mse       = varargin{4};
    if nargin==5
      algo = varargin{5};
      dy = [];
    elseif nargin==6
      algo = varargin{5};
      dy = varargin{6};
    else
      % default is jacobian for back compatibility
      algo = 'jacobian';
      dy = [];
    end
    
  else
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Assume loglikelihood(sys, plist)
    [mfh_in, mfh_invars] = utils.helper.collect_objects(varargin(:), 'mfh',   in_names);
    pl                   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
    % Combine plists
    pl = applyDefaults(getDefaultPlist, pl);
  
    % copy input ssm
    f = copy(mfh_in,1);
    
    pars      = find_core(pl, 'pars');
    DerivStep = find_core(pl, 'DerivStep');
    mse       = find_core(pl, 'mse');
    algo      = find_core(pl, 'algo');
    dy        = find_core(pl, 'dy');
  
  end
  
  if ~isa(pars,'pest')
    error('''pars'' parameter must be a ''pest'' object!')
  end
  
  out = copy(pars,1);
  
  % get covariance matrix
  covobj = paramCovMat(f,pars.y,DerivStep,mse,algo,dy);
  covmat = covobj.y;
  
  % get errors
  errs = sqrt(diag(covmat));
  
  % build ao object
  out.setDy(errs);
  out.setCov(covmat);
  out.setChi2(mse);
  out.setModels(f);
  
  % add history
  if ~callerIsMethod
    out.addHistory(getInfo('None'), pl, [], f.hist);
  end
  
  varargout = utils.helper.setoutputs(nargout, out);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl = getDefaultPlist()
  
  pl = plist();

  p = param({'pars', 'The set of parameter values. A pest object.'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'DerivStep', 'The set of derivative steps. A NumParams x 1 array'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'mse', 'Fit mean square error.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  p = param({'algo', 'Algorithm used to calculate the covariance matrix.'}, {1, {'jacobian', 'hessian'}, paramValue.SINGLE});
  pl.append(p);
  
  p = param({'dy', 'Errors on y measurements. If you input dy the function does not compensates for mse.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

