% LSCOV is a wrapper for MATLAB's lscov function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LSCOV is a wrapper for MATLAB's lscov function. It solves a
% set of linear equations by performing a linear least-squares fit. It
% solves the problem
%
%        Y = HX
%
%   where X are the parameters, Y the measurements, and H the linear
%   equations relating the two.
%
% CALL:        X = lscov([C1 C2 ... CN], Y, pl)
%              X = lscov(C1,C2,C3,...,CN, Y, pl)
%
% INPUTS:      C1...CN - AOs which represent the columns of H.
%              Y       - AO which represents the measurement set
%
% Note: the length of the vectors in Ci and Y must be the same.
% Note: the last input AO is taken as Y.
%
%              pl - parameter list (see below)
%
% OUTPUTs:     X  - A pest object with fields: 
%                   y   - the N fitting coefficients to y_i 
%                   dy  - the parameters' standard deviations (lscov 'STDX' vector)
%                   cov - the parameters' covariance matrix (lscov 'COV' vector)
%                   
% The procinfo field of the output PEST object is filled with the following key/value
% pairs:
%     'MSE' - the mean-squared errors
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lscov')">Parameters Description</a>
%
% EXAMPLES:
%
% % 1) Determine the coefficients of a linear combination of noises:
%
% % Make some data
%  fs    = 10;
%  nsecs = 10;
%  B1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%  B2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%  B3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
%  c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/T')) ao(3,plist('yunits','m T^-1'))];
%  y = c(1)*B1 + c(2)*B2 + c(3)*B3 + n;
%  y.simplifyYunits;
%  % Get a fit for c
%  p_s = lscov(B1, B2, B3, y);
%  % do linear combination: using lincom
%  yfit1 = lincom(B1, B2, B3, p_s);
%  yfit1.simplifyYunits;
%  % do linear combination: using eval
%  yfit2 = p_s.eval(B1, B2, B3);
% 
%  % Plot (compare data with fit)
%  iplot(y, yfit1, yfit2, plist('Linestyles', {'-','--'}))
%
% % 2) Determine the coefficients of a linear combination of noises:
%
% % Make some data
%  fs    = 10;
%  nsecs = 10;
%  x1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%  x2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
%  x3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'C'));
%  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
%  c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/m')) ao(3,plist('yunits','m C^-1'))];
%  y = c(1)*x1 + c(2)*x2 + c(3)*x3 + n;
%  y.simplifyYunits;
%  % Get a fit for c
%  p_m = lscov(x1, x2, x3, y);
%  % do linear combination: using lincom
%  yfit1 = lincom(x1, x2, x3, p_m);
%  % do linear combination: using eval
%  pl_split = plist('times', [1 5]);
%  yfit2 = p_m.eval(plist('Xdata', {split(x1, pl_split), split(x2, pl_split), split(x3, pl_split)}));
%  % Plot (compare data with fit)
%  iplot(y, yfit1, yfit2, plist('Linestyles', {'-','--'}))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lscov(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [A, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  if numel(A) < 2
    error('### lscov needs at least 2 inputs AOs');
  end
  
  if nargout == 0
    error('### lscov can not be used as a modifier method. Please give at least one output');
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % collect inputs names
  argsname = ao_invars{1};
  for jj = 2:numel(A)
    argsname = [argsname ',' ao_invars{jj}];
  end
  
  % Extract parameters
  W = find_core(pl, 'weights');
  V = find_core(pl, 'cov');
  
  if ~isempty(W) && ~isempty(V)
    error('Please specify either the weight vector or the covariance matrix, but not both!');
  end
  
  % Build matrices for lscov: base functions and data
  C = A(1:end-1);
  Y = A(end);
  
  H = C(:).y;
  y = Y.y;
    
  % vectors length
  N = length(y);
  
  % Look for uncertainties in the base functions
  dH = [];
  for jj = 1:size(H, 2)
    dh = C(jj).dy;
    if isempty(dh)
      dh = zeros(N, 1);
    end
    dH = [dH dh];
  end

  if all(dH == 0)
    dH = [];
  end
  
  % Looking for user input weights
  if isa(W, 'ao'), W = W.y; end;
  if isrow(W)
    W  =  W';
  end
  
  % Looking for user input covariance
  if isa(V, 'ao'), V = V.y; end;
    
  % Call Matlab's lscov, using the weights by default
  if isempty(V)
    [p, stdx, mse, s] = lscov(H, y, W);
    % Take into account uncertainties in the base functions
    if ~isempty(dH) && ~isempty(W)
      % propaagate the dx errors via the first parameter estimates. Idea:
      % dy_est^2 = dy.^2 + sum((m_i .* dx_i).^2);
      dy2 = 1 ./ W;
      for kk = 1:numel(p)
        dy2 = dy2 + (p(kk) * dH(:, kk)).^2;
      end
      W = 1 ./ dy2;
      [p, stdx, mse, s] = lscov(H, y, W);
    end
  else
    [p, stdx, mse, s] = lscov(H, y, V);
  end
  
  if ~isempty(V) || ~isempty(W)
    % scale errors and covariance matrix
    stdx = stdx ./ sqrt(mse);
    s    = s ./ mse;
  end

  % prepare model, units, names
  model = [];
  for jj = 1:numel(p)
    names{jj} = ['C' num2str(jj)];
    units{jj} = Y.yunits / C(jj).yunits;
    xunits{jj} = C(jj).yunits;
    xvar{jj} = ['X' num2str(jj)];
    if jj == 1
      model = ['C' num2str(jj) '*X' num2str(jj) ' '];
    else
      model = [model ' + C' num2str(jj) '*X' num2str(jj)];
    end
  end
  
  % degrees of freedom and chi2
  dof = N - length(p);

  if isempty(V)
    if ~isempty(W)
      chi2 = sum((y - lincom(H, p)).^2 .* W) / dof;
    else
      chi2 = 1;
    end
  else
    chi2 = sum((y - lincom(H, p)).^2 .* 1 ./ diag(V)) / dof;
  end
  
  % Prepare the smodel
  model = smodel(plist('expression', model, ...
    'params', names, ...
    'values', p, ...
    'xvar', xvar, ...
    'xunits', xunits, ...
    'yunits', Y.yunits ...
    ));  
  
  % Build the output pest object
  X = pest;
  X.setY(p);
  X.setDy(stdx);
  X.setCov(s);
  X.setChi2(chi2);
  X.setDof(dof);
  X.setNames(names{:});
  X.setYunits(units{:});
  X.setModels(model);
  X.name = sprintf('lscov(%s)', argsname);
  X.addHistory(getInfo('None'), pl, ao_invars, [A(:).hist]);
  % Set procinfo object
  X.procinfo = plist('MSE', mse);
  % Propagate 'plotinfo'
  plotinfo = [A(:).plotinfo];
  if ~isempty(plotinfo)
    X.plotinfo = combine(plotinfo);
  end
  
  % Set outputs
  varargout{1} = X;
    
end

%--------------------------------------------------------------------------
% computes linear combination
%--------------------------------------------------------------------------

function out = lincom(x, p)
  assert(size(x, 2) == length(p));
  out = zeros(size(x, 1), 1);
  for k = 1:length(p)
    out = out + x(:,k) * p(k);
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
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
  
  % Weights
  p = param({'weights', 'An ao containing weights for the fit.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Cov
  p = param({'cov', 'An ao containing a covariance matrix for the fit.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end
% END
