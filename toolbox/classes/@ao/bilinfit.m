% BILINFIT is a linear fitting tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BILINFIT linear fitting tool based on MATLAB's lscov
% function. It solves an equation in the form
%
%     Y = X(1) * P(1) + X(2) * P(2) + ... + P(N+1)
%
% for the fit parameters P. It handles an arbitrary number of input vectors
% and uncertainties on the dependent vector Y and input vectors X(1..N).
% The output is a pest object where the fields are containing:
% Quantity                              % Field
% Fit coefficients                          y
% Uncertainties on the fit parameters
% (given as standard deviations)            dy
% The reduced CHI2 of the fit              chi2
% The covariance matrix                    cov
% The degrees of freedom of the fit        dof
%
% CALL:       P = bilinfit(X1, X2, .., XN, Y, PL)
%
% INPUTS:     Y       - dependent variable
%             X(1..N) - input variables
%             PL      - parameter list
%
% OUTPUT:     P   - a pest object with the N+1 elements
%
%
% PARAMETERS:
%    'dy' - uncertainty on the dependent variable
%    'dx' - uncertainties on the input variables
%    'p0' - initial guess on the fit parameters to propagate uncertainities
%           in the input variables X(1..N) to the dependent variable Y
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'bilinfit')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1) Determine the coefficients of a linear combination of sine waves + noise:
%
% % Make some data
% fs    = 10;
% nsecs = 10;
% A1 = 5;
% f1 = 1;
% A2 = 3;
% f2 = 0.2;
% x1 = ao(plist('waveform', 'sine', 'A', A1, 'f', f1, 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
% x2 = ao(plist('waveform', 'sine', 'A', A2, 'f', f2, 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
%  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
%  c = [ao(1,plist('yunits','m/m')) ao(2,plist('yunits','m/m'))];
%  y = c(1)*x1 + c(2)*x2 + n;
%  y.simplifyYunits;
%
% % Get a fit for the c coefficients and a constant term
%  p = bilinfit(x1, x2, y)
%
% % Do linear combination: using eval
%  pl_split = plist('times', [1 5]);
%  yfit = eval(p, split(x1, pl_split), split(x2, pl_split));
%
% % Plot (compare data with fit)
% iplot(y, yfit, plist('Linestyles', {'-','--'}))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = bilinfit(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % tell the system we are runing
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect all AOs and plists
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl               = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### bilinfit can not be used as a modifier method. Please give at least one output');
  end
  
  if numel(aos) < 2
    error('### bilinfit needs at least 2 inputs AOs');
  end
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % collect inputs
  Y = aos(end);
  X = aos(1:end-1);
  
  % collect inputs names
  argsname = ao_invars{1};
  for jj = 2:numel(aos)
    argsname = [argsname ',' ao_invars{jj}];
  end
  
  % get data from AOs
  x  = X(:).y;
  y  = Y.y;
  dy = Y.dy;
  dx = X(:).dy; % Maybe we need something better here
  
  % extract plist parameters. For dx and dy we check the user input plist before
  if ~isempty(find_core(pl, 'dy'))
    dy = find_core(pl, 'dy');
  end
  if ~isempty(find_core(pl, 'dx'))
    dx = find_core(pl, 'dx');
  end
  p0 = find_core(pl, 'p0');
  
  % vectors length
  N = length(y);
  
  % constant term
  c = ones(N, 1);
  
  % build matrix
  m = [x c];
  
  % uncertainty on Y
  if ~isempty(dy)
    noerrors = false;
    if isa(dy, 'ao')
      % check units
      if ~isequal(Y.yunits, dy.yunits)
        error('### Y and DY units are not compatible - %s %s', char(Y.yunits), char(dy.yunits));
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
  
  % number of parameters
  num_params = length(X) + 1;
  
  % number of degrees of freedom
  dof = N - num_params;
  
  % Prepare the vector of weights
  if noerrors
    sigma2 = [];
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
    sigma2_post = sum(1 / dof .* (y - lincom(m, p)).^2) .* ones(size(y));
    
    % call the routine again using these estimated uncertainties
    [p, stdp, mse, s] = lscov(m, y, 1./sigma2_post);
    
  else
    % uncertainty on X
    if ~isempty(dx)
      
      if length(p0) ~= num_params
        p0 = p;
      end

      for k = 1:size(dx, 2)
        dxi = dx(:, k);
        
        if ~isempty(dxi)
          if isa(dxi, 'ao')
            % check units
            if ~isequal(X(k).yunits, dxi.yunits)
              error('### X and DX units are not compatible - %s %s', char(X.yunits), char(dxi.yunits));
            end
            % extract values from AO
            dxi = dxi.y;
          end
          if isscalar(dxi)
            % given a single value construct a vector
            dxi = ones(N, 1) * dxi;
          end
          
          % squares
          sigma2xi = dxi.^2;
          
          % add contribution to weights
          sigma2 = sigma2 + sigma2xi * p0(k)^2;
        end
        
      end
      
      % call the routine again using these estimated uncertainties
      [p, stdp, mse, s] = lscov(m, y, 1./sigma2);

    end
    
    % scale errors and covariance matrix
    stdp = stdp ./ sqrt(mse);
    s    = s ./ mse;
    
    % compute chi2
    dof = N - length(p);
    chi2 = sum((y - lincom(m, p)).^2 ./ sigma2) / dof;
    
  end
  
  % extract values for initial guess
  if (isa(p0, 'ao') || isa(p0, 'pest'))
    p0 = p0.y;
  end
  
  % prepare model, units, names
  model = [];
  for kk = 1:length(p)
    switch kk
      case 1
        units(kk) = simplify(Y.yunits/X(kk).yunits);
        model = ['P' num2str(kk) '*X' num2str(kk)];
        xvar{kk} = ['X' num2str(kk)];
        xunits{kk} = X(kk).yunits;
      case length(p)
        units(kk) = Y.yunits;
        model = [model ' + P' num2str(kk)];
      otherwise
        units(kk) = simplify(Y.yunits/X(kk).yunits);
        model = [model ' + P' num2str(kk) '*X' num2str(kk)];
        xvar{kk} = ['X' num2str(kk)];
        xunits{kk} = X(kk).yunits;
    end
    names{kk} = ['P' num2str(kk)];
    
  end
  model = smodel(plist('expression', model, ...
    'params', names, ...
    'values', p, ...
    'xvar', xvar, ...
    'xunits', xunits, ...
    'yunits', Y.yunits));
  
  
  % build the output pest object
  out = pest;
  out.setY(p);
  out.setDy(stdp);
  out.setCov(s);
  out.setChi2(chi2);
  out.setDof(dof);
  out.setNames(names{:});
  out.setYunits(units);
  out.setModels(model);
  out.name = sprintf('bilinfit(%s)', argsname);
  out.addHistory(getInfo('None'), pl,  ao_invars, [aos(:).hist]);
  % set procinfo object
  out.procinfo = plist('MSE', mse);
  
  % set outputs
  varargout{1} = out;
  
end

% computes linear combination
function out = lincom(x, p)
  assert(size(x, 2) == length(p));
  out = zeros(size(x, 1), 1);
  for k = 1:length(p)
    out = out + x(:,k) * p(k);
  end
end

% get info object
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
end

% get default plist

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  % default plist for linear fitting
  pl = plist.MULTILINEAR_FIT_PLIST;
  
end
