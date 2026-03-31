% POLYNOMFIT is a polynomial fitting tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: POLYNOMFIT is a polynomial fitting tool based on MATLAB's
% lscov function. It solves an equation in the form
%
%     Y = P(1) * X^N(1) + P(2) * X^N(2) + ...
%
% for the fit parameters P. It handles arbitrary powers of the input vector
% and uncertainties on the dependent vector Y and input vectors X.
% The output is a pest object where the fields are containing:
% Quantity                              % Field
% Fit coefficients                          y
% Uncertainties on the fit parameters
% (given as standard deviations)            dy
% The reduced CHI2 of the fit              chi2
% The covariance matrix                    cov
% The degrees of freedom of the fit        dof
%
% CALL:       P = polynomfit(X, Y, PL)
%             P = polynomfit(A, PL)
%
% INPUTS:     Y   - dependent variable
%             X   - input variables
%             A   - data ao whose x and y fields are used in the fit
%             PL  - parameter list
%
% OUTPUT:     P   - a pest object with M = numel(N) fitting coefficients
%
%
% PARAMETERS:
%    'orders' - polynom orders. Eg [0,1,-2] fits to P0 + P1*x + P2./x.^2
%    'dy'     - uncertainty on the dependent variable
%    'dx'     - uncertainties on the input variable
%    'p0'     - initial guess on the fit parameters used ONLY to propagate
%               uncertainities in the input variable X to the dependent variable Y
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'polynomfit')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1) Fit with one object input
%
% nsecs = 5;
% fs    = 10;
% n       = [0 1 -2];
% u1 = unit('mV');
%
% pl1 = plist('nsecs', nsecs, 'fs', fs, ...
%   'tsfcn', sprintf('t.^%d + t.^%d + t.^%d + randn(size(t))', n), ...
%   'xunits', 's', 'yunits', u1);
% a1 = ao(pl1);
% out1 = polynomfit(a1, plist('orders', n, 'dx', 0.1, 'dy', 0.1, 'P0', zeros(size(n))));
%
% % 2) Fit with two objects input
%
% fs      =  1;
% nsecs   = 10;
% n       = [0 1 -2];
%
% X = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm', 'name', 'base'));
% N = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm', 'name', 'noise'));
% C = [ao(1, plist('yunits', 'm', 'name', 'C1')) ...
%      ao(4, plist('yunits', 'm/m', 'name', 'C2')) ...
%      ao(2, plist('yunits', 'm/m^(-2)', 'name', 'C3'))];
% Y = C(1) * X.^0 + C(2) * X.^1 + C(3) * X.^(-2) + N;
% Y.simplifyYunits;
% out2 = polynomfit(X, Y, plist('orders', n))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = polynomfit(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % tell the system we are running
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect all AOs and plists
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pli              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### polynomfit can not be used as a modifier method. Please give at least one output');
  end
  
  % combine plists, making sure the user input is not empty
  pli = combine(pli, plist());
  pl = applyDefaults(getDefaultPlist(), pli);
  
  % extract arguments
  if (length(aos) == 1)
    % we are using x and y fields of the single ao we have
    x = aos(1).x;
    dx = aos(1).dx;
    y = aos(1).y;
    dy = aos(1).dy;
    xunits = aos(1).xunits;
    yunits = aos(1).yunits;
    argsname = ao_invars{1};
  elseif (length(aos) == 2)
    % we are using y fields of the two aos we have
    x = aos(1).y;
    dx = aos(1).dy;
    y = aos(2).y;
    dy = aos(2).dy;
    xunits = aos(1).yunits;
    yunits = aos(2).yunits;
    argsname = [ao_invars{1} ',' ao_invars{2}];
  else
    error('### polynomfit needs one or two input AOs');
  end
  
  % extract plist parameters. For dx and dy we check the user input plist before
  if ~isempty(find_core(pl, 'dx'))
    dx = find_core(pl, 'dx');
  end
  if ~isempty(find_core(pl, 'dy'))
    dy = find_core(pl, 'dy');
  end
  orders  = find_core(pl, 'orders');
  p0      = find_core(pl, 'p0');
  
  % vectors length
  N = length(y);
  
  % uncertainty on Y
  if ~isempty(dy)
    noerrors = false;
    if isa(dy, 'ao')
      % check units
      if ~isequal(yunits, dy.yunits)
        error('### Y and DY units are not compatible - %s %s', char(yunits), char(dy.yunits));
      end
      % extract values from AO
      dy = dy.y;
    end
    if isscalar(dy)
      % given a single value construct a vector
      dy = ones(N, 1) * dy;
    end
  else
    noerrors = true;
  end
  
  if ~isempty(dx)
    if isa(dx, 'ao')
      % check units
      if ~isequal(xunits, dx.yunits)
        error('### X and DX units are not compatible - %s %s', char(xunits), char(dx.yunits));
      end
      % extract values from AO
      dx = dx.y;
    end
    if isscalar(dx)
      % given a single value construct a vector
      dx = ones(N, 1) * dx;
    end
  end
  
  % number of parameters
  num_params = length(orders);
  
  % number of degrees of freedom
  dof = N - num_params;
  
  % construct a matrix with desired powers of X
  m = zeros(length(x), num_params);
  for k = 1:num_params
    m(:,k) = x .^ orders(k);
  end
  
  % check for the presence of 1/0 terms
  idx = all(isfinite(m), 2);
  m = m(idx, :);
  x = x(idx);
  y = y(idx);
  N = length(y);
  
  if ~isempty(dy)
    dy = dy(idx);
  end
  if ~isempty(dx)
    dx = dx(idx);
  end
  
  % Prepare the vector of weights
  if noerrors
    sigma2 = ones(size(y));
  else
    sigma2 = dy.^2;
  end
    
  % solve
  [p, stdp, mse, s] = lscov(m, y, 1./sigma2);

  if noerrors
    % The user did not provide dy errors
    
    % assign the reduced Chi^2 a value of 1
    chi2 = 1;

    % estimate 'a posteriori' the data uncertainty
    sigma2_post = sum(1 / dof .* (y - polynomeval(x, orders, p)).^2) .* ones(size(y));
    
    % call the routine again using these estimated uncertainties
    [p, stdp, mse, s] = lscov(m, y, 1./sigma2_post);
    
  else
    
    % uncertainty on X
    if ~isempty(dx)
      % extract values for initial guess
      if (isa(p0, 'ao') || isa(p0, 'pest'))
        p0 = p0.y;
      end
    
      if length(p0) ~= num_params
        p0 = p;
      end
      
      % propagate X uncertainty on Y
      dy_dx_mod = zeros(N, 1);
      for k = 1:num_params
        % we need to skip the constant terms since 0*Inf = NaN
        if orders(k) ~= 0
          dy_dx_mod = dy_dx_mod + orders(k) * p0(k) * x.^(orders(k)-1);
        end
      end
      sigma2x = dy_dx_mod.^2 .* dx.^2;
      
      % add contribution to weights
      sigma2 = sigma2 + sigma2x;
      
      % call the routine again using these estimated uncertainties
      [p, stdp, mse, s] = lscov(m, y, 1./sigma2);
    end
    
    % check for the presence of 1/0 terms
    S = [];
    kk = 0;
    
    idx = isfinite(m);
    for jj = 1:size(m, 1)
      if all(idx(jj, :))
        kk = kk + 1;
        S(kk,:) = sigma2(jj, :);
      end
    end
    sigma2 = S; clear S;
    N = kk;
    
    % scale errors
    stdp = stdp ./ sqrt(mse);
    s    = s ./ (mse);
    
    % compute chi2
    dof = N - length(p);
    chi2 = sum((y - polynomeval(x, orders, p)).^2 ./ sigma2) / dof;

  end
    
  % prepare model, units, names
  model = [];
  for kk = 1:length(p)
    if kk == 1
      model = [model 'P' num2str(kk) '*X.^(' num2str(orders(kk)) ')'];
    else
      model = [model ' + P' num2str(kk) '*X.^(' num2str(orders(kk)) ')'];
    end
    units(kk) = simplify(yunits/xunits.^(orders(kk)));
    names{kk} = ['P' num2str(kk)];
  end
  model = smodel(plist('expression', model, ...
    'params', names, ...
    'values', p, ...
    'xvar', 'X', ...
    'xunits', xunits, ...
    'yunits', yunits ...
    ));
  
  
  % Build the output pest object
  out = pest;
  out.setY(p);
  out.setDy(stdp);
  out.setCov(s);
  out.setChi2(chi2);
  out.setDof(dof);
  out.setNames(names{:});
  out.setYunits(units);
  out.setModels(model);
  out.name = sprintf('polynomfit(%s)', argsname);
  out.addHistory(getInfo('None'), pl,  ao_invars, [aos(:).hist]);
  % Set procinfo object
  out.procinfo = plist('MSE', mse);
  
  % set outputs
  varargout{1} = out;
  
end

%--------------------------------------------------------------------------
% Polynomial Model Evaluation
%--------------------------------------------------------------------------

function out = polynomeval(x, n, p)
  assert(length(p) == length(n));
  out = zeros(size(x, 1), 1);
  for k = 1:length(n)
    out = out + p(k) * x.^n(k);
  end
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
    pl   = getDefaultPlist();
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  % orders
  p = param({'orders', 'Polynom orders.'}, [0]);
  pl.append(p);
  
  % default plist for linear fitting
  pl.append(plist.LINEAR_FIT_PLIST);
  
end
