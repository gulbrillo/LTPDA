% POWERFIT fits a piecewise powerlaw to the given data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: POWERFIT fits a piecewise powerlaw to the given data by
%              minimising the log-likelihood function.
%
%
% CALL:        out = obj.powerFit(pl)
%              out = powerFit(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - some output.
%
%
% Created 2013-02-20, M Hewitson
%     - adapted from code writen by Curt Cutler and Ira Thorpe.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'powerFit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = powerFit(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ao
  [objs, obj_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  objsCopy = copy(objs, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Extract input parameters from the plist
  gamma = double(pl.find_core('orders'));
  p0    = double(pl.find_core('p0'));
  offsets = double(pl.find_core('OFFSETS'));
  UB = double(pl.find_core('UB'));
  LB = double(pl.find_core('LB'));
  
  
  USE_FMIN = isempty(UB) && isempty(LB);
  
  % check number of parameters
  if isempty(p0)
    error('Please specify an initial guess for the parameter vector');
  end
  
  % check upper bounds and assign defaults
  if isempty(UB)
    UB = Inf*ones(size(p0));
  end
  
  if numel(UB) ~= numel(p0)
    error('Number of upper bounds must match number of parameters');
  end
  
  % check lower bounds and assign defaults
  if isempty(LB)
    LB = -Inf*ones(size(p0));
  end
  
  if numel(LB) ~= numel(p0)
    error('Number of upper bounds must match number of parameters');
  end
  
  % check offsets
  if isempty(offsets)
    offsets = zeros(size(p0));
  else
    if numel(offsets) ~= numel(p0)
      error('Number of offsets must match the number of parameters');
    end
  end
  
  % Loop over input objects
  for jj = 1 : numel(objsCopy)
    % Process object jj
    object = objsCopy(jj);
    
    % get data
    x = object.x';
    y = transpose(double(object));
    xunits = object.xunits;
    yunits = object.yunits;
    
    % check/apply weights
    w = pl.find_core('WEIGHTS');
    if ~isempty(w)
      switch class(w)
        case {'double','ao'}
          w = transpose(double(w));
          if numel(w) ~= numel(y)
            error('Weight vector must be same length as data vector');
          end
        case 'plist'
          if isempty(w.find('built-in'))
            error('weighting vector plist must be for a built-in AO model')
          end
          
          % build model to get weighting vector
          w = transpose(double(ao(w.append('F',x'))));
        otherwise
          error('%s objects are not valid weighting vectors', class(w));
      end
    else
      w = ones(size(y))/numel(y);
    end
    
    
    % Apply Curt's fitting code
    
    % strip off first element (if it is DC)
    if x(1) == 0
      xfit = x(2:end);
      yfit = y(2:end);
      w = w(2:end);
    else
      xfit = x;
      yfit = y;
    end
    
    % define frequency slopes
    N = length(yfit);
    L = length(gamma);
    fgam = zeros(L,N);
    for k = 1:L
      fgam(k,:) = (xfit+offsets(k)).^gamma(k);
    end
    
    % define fitting funciton and apply fit
    Lfunc = pl.find('Function');
    switch lower(Lfunc)
      case 'sum'
        fitfcn = @(x) sum(w.*(yfit./(x*fgam) - log(yfit./(x*fgam))) );
      case 'median'
        fitfcn = @(x) median(w.*(yfit./(x*fgam) - log(yfit./(x*fgam))) );
      case 'exponential'
        K = double(pl.find('EXP_FACT'));
        fitfcn = @(x) sum(w.*(-K*exp(-(1/K)*yfit./(x*fgam))+K-log(yfit./(x*fgam)) ));
      otherwise
    end
    
    if USE_FMIN
      paramOut = fminsearch(fitfcn, p0);
    else
      paramOut = utils.math.fminsearchbnd_core(fitfcn, p0,LB,UB);
    end
    
    % prepare model, units, names
    model = [];
    for kk = 1:length(gamma)
      if kk == 1
        model = [model 'P' num2str(kk) '*(X+' num2str(offsets(kk)), ').^(' num2str(gamma(kk)) ')'];
      else
        model = [model ' + P' num2str(kk) '*(X+' num2str(offsets(kk)), ').^(' num2str(gamma(kk)) ')'];
      end
      units(kk) = simplify(yunits/xunits.^(gamma(kk)));
      names{kk} = ['P' num2str(kk)];
    end
    
    model = smodel(plist('expression', model, ...
      'params', names, ...
      'values', paramOut, ...
      'xvar', 'X', ...
      'xunits', xunits, ...
      'yunits', yunits ...
      ));
    
    
    % Build the output pest object
    out(jj) = pest;
    out(jj).setY(paramOut);
    out(jj).setNames(names{:});
    out(jj).setYunits(units);
    out(jj).setModels(model);
    
    if ~isempty(object.plotinfo)
      out(jj).plotinfo = copy(object.plotinfo, 1);
    end
    
    out(jj).name = sprintf('powerFit(%s)', obj_invars{jj});
    out(jj).addHistory(getInfo('None'), pl,  obj_invars(jj), object.hist);
    
  end % loop over analysis objects
  
  % Set output
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  % Create empty plsit
  pl = plist();
  
  % Orders
  p = param(...
    {'orders', 'The powers of the dependent variable to fit to the data.'},...
    paramValue.DOUBLE_VALUE(0)...
    );
  pl.append(p);
  
  % p0
  p = param(...
    {'p0', 'An initial guess for the power-law coefficients.'},...
    paramValue.DOUBLE_VALUE(1)...
    );
  pl.append(p);
  
  % offsets
  p = param(...
    {'OFFSETS', 'offset frequencies of the power-law from DC.'},...
    paramValue.EMPTY_DOUBLE...
    );
  pl.append(p);
  
  % UB
  p = param({'UB', 'Array of upper bounds for parameters. If empty, the upper bound is +Inf for all variables.'}, []);
  pl.append(p);
  
  % LB
  p = param({'LB', 'Array of lower bounds for parameters. If empty, the lower bound is -Inf for all variables.'}, []);
  pl.append(p);
  
  % Weights
  p = param({'WEIGHTS','Weights for individual data bins. If empty, all bins are weighted equally. Can also be a plist for a built-in ao model'},...
    paramValue.EMPTY_DOUBLE()...
    );
  pl.append(p);
  
  % Function
  p = param(...
    {'Function',['Function to use when calculating the liklihood.<ul>'...
    '<li>Sum - Sum the likelihood over all bins</li>', ...
    '<li>Median - Take the median likelihood over all bins</li>', ...
    '<li>Exponential - Apply an exponential weighting to the likelihood to reduce influence of noise spikes</li>', ...
    '</ul>']},...
    {1, {'Sum', 'Median','Exponential'}, paramValue.SINGLE});
  pl.append(p);
  
  % EXP_FACT
  p = param({'EXP_FACT', 'Factor used in exponential weighting of likelihood funciton'}, 7);
  pl.append(p);
  
  
end

% END
