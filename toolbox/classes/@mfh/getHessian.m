% GETHESSIAN calculate Hessian matrix for a given function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GETHESSIAN calculate Hessian matrix for a given function. Each function
%             is assumed to be function only of the parameters resepect to
%             which the derivative should be calculated. All the other
%             quantities should be inserted in the 'constants' field.
%
% CALL:                H = getHessian(func,pl)
%
% INPUTS:
%         - func. The cost function
%
% PARAMETERS:
%         - p0. The set of parameters. (double vector or a pest object).
%         - DerivStep. The set of derivative steps. (doble vactor).
%
% OUTPUTS:
%         - H. the Hessian matrix. q x q where q is numel(p0).
%
% ALGORITHM:
%
% Reference to the wikipedia page on Finite difference, paragraph Finite
% difference in several variables.
% http://en.wikipedia.org/wiki/Finite_difference
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'getHessian')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = getHessian(varargin)
  
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
  
    % copy input ssm
    f = copy(mfh_in,1);
    
    theta      = find_core(pl, 'pars');
    DerivStep = find_core(pl, 'DerivStep');
  
  end
  
  if isa(theta,'pest')
    % get parameters out
    theta = theta.y;
  end
  
  % create function handle
  fh_str = f.function_handle();
  
  % declare objects locally
  declare_objects(f);
  
  % create function handle
  func = eval(fh_str);
  
  % make double the parameters
  % theta = double(p0);
  dStep = double(DerivStep);
  
  % evaluate function at p0
  y0 = func(theta);
  if isa(y0,'ao')
    y0 = y0.y;
  end
  % sanity check
  if numel(y0)>1
    error('The cost function is supposed to produce 1 number when evaluated on the parameters');
  end
  
  % calculate Hessian matrix
  numParams = numel(theta);
  H = zeros(numParams,numParams);
  
  for ii=1:numParams
    for jj=1:numParams
      if ii==jj
        pVplus = theta;
        pVminus = theta;
        pVplus(ii) = theta(ii) + dStep(ii);
        pVminus(ii) = theta(ii) - dStep(ii);

        yp = abs(func(pVplus));
        if isa(yp,'ao')
          yp = yp.y;
        end
        ym = abs(func(pVminus));
        if isa(ym,'ao')
          ym = ym.y;
        end

        D = (dStep(ii))^2;

        H(ii,jj) = (yp - 2*y0 + ym)./D;
        
      else
        
        pVpp = theta;
        pVpm = theta;
        pVmp = theta;
        pVmm = theta;
        
        pVpp(ii) = theta(ii) + dStep(ii);
        pVpp(jj) = theta(jj) + dStep(jj);
        
        pVpm(ii) = theta(ii) + dStep(ii);
        pVpm(jj) = theta(jj) - dStep(jj);
        
        pVmp(ii) = theta(ii) - dStep(ii);
        pVmp(jj) = theta(jj) + dStep(jj);
        
        pVmm(ii) = theta(ii) - dStep(ii);
        pVmm(jj) = theta(jj) - dStep(jj);
        
        ypp = abs(func(pVpp));
        ypm = abs(func(pVpm));
        ymp = abs(func(pVmp));
        ymm = abs(func(pVmm));
        
        D = 4*dStep(ii)*dStep(jj);
        
        H(ii,jj) = (ypp - ypm - ymp + ymm)./D;
        
      end
    end
  end
  
  % create output object
  out = ao(H);
  
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
