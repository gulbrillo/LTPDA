% MULTINEST.M
%
% MultiNest is a Bayesian inference tool which calculates the evidence and 
% explores the parameter space which may contain multiple posterior modes 
% and pronounced (curving) degeneracies in moderately high dimensions. 
%
% For more information about the algorithm see arXiv:0809.3437 
%
% CALL:
%         p = multinest(c, plist);
%
% where     p - pest object containing the results of the fit
%           c - a cost function. Must be a mfh object
%       plist - a given plist    
%
%
% USE OF PRIORS:
% 
%   The prior should be a cell array with each cell containing five values:
%   
%   prior = { parameter_name (string); prior_type (string); prior_specs, prior_behaviour (string)};
%     
%   where 
%   prior_type      -> 'uniform', 'gaussian' of 'jeffreys'
%   prior_specs     -> prior specifications: min val, max val, mean, sigma
%   prior_behaviour -> 'reflect' - if the parameters reflect off the boundaries
%                      'cyclic'  - if the parameter space is cyclic
%                      'fixed'   - if the parameters have fixed boundaries
%                      ''        - for gaussian priors
%
%   e.g., prior = {'h0',  'uniform',  0, 1,    'reflect';
%                  'r',   'gaussian', 0, 5,    '';
%                  'phi', 'uniform',  0, 2*pi, 'cyclic'};
%
%
%
%
% EXAMPLE:
% 
%       % Create some data and make a data set to fit
%       fs    = 1;
%       nsecs = 2e3;
%       B1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%       B2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%       B3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
%       n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
% 
%       % Noise of the experiment
%       n_exp = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', 10*nsecs, 'yunits', 'm'));
% 
%       % Combination parameters
%       c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/T')) ao(3,plist('yunits','m T^-1'))];
% 
%       % Define here the data to fit
%       y = c(1)*B1 + c(2)*B2 + c(3)*B3 + n;
%       y.simplifyYunits;
% 
%       % Get a fit for c with a linear fitter
%       p_s = lscov(B1, B2, B3, y);
%       p_s.setName('lscov');
% 
%       % do linear combination: using lincom
%       yfit = lincom(B1, B2, B3, p_s);
%       yfit.simplifyYunits;
% 
%       % Create a MFH model of the above data analysis
%       mdl = mfh(plist(...
%                       'name',             'temp',...
%                       'built-in',         'custom',...      
%                       'numeric',          true,...  
%                       'params',           p_s,...
%                       'func',             'C1.*B1 + C2.*B2 + C3.*B3',...  
%                       'constants',        {'B1','B2','B3'},...
%                       'constant objects', {B1,B2,B3}));
% 
%       % Define a log-Likelihood function
%       llh = mfh(plist('built-in',     'loglikelihood', ...
%                       'version',      'td core',...
%                       'name',         'Gaussian td',...
%                       'model',        mdl,...        
%                       'data',         y,... 
%                       'p0',           p_s));
% 
%       llh.setName('LLH');
% 
%       %% Run multinest    
%
%       % Define the prior
%       prior = {'C1', 'uniform', -1, 3, 'fixed'; ...
%                'C2', 'uniform', 0, 5,  'fixed'; ...
%                'C3', 'uniform', 1, 8,  'fixed'};
% 
%       p = multinest(llh, plist('p0',    p_s,...
%                                'Nlive', 300, ...
%                                'prior', prior));             
%       
%       % Plot the parameter PDFs
%       p.mcmcPlot(plist('chains',0,'plot fit curves',0,'nbins',60,...
%                        'burnin',2, 'pdfs', true,'hist type', 'stairs', ...
%                        'plot cumsum',0,'plotmatrix',true))
%
%       % Compare
%       table(p_s, p)
%
%
%
%
%
% This function is an LTPDA wrapper of the Matlab version of the Multinest
% algorithm. The original functions are copied here verbatim, apart from
% minor changes needed to support the LTPDA environment. The original code
% is available here:
%
% https://ccpforge.cse.rl.ac.uk/gf/project/multinest/
% https://github.com/mattpitkin/matlabmultinest
%
% Copyright (C) 2012 Matthew Pitkin & Joseph Romano
%
% Translation to LTPDA by NK 2017
%

function varargout = multinest(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### MULTINEST cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [mfh_in, mfh_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  pl          = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);

  % copy input aos
  llh  = copy(mfh_in,1); 
  
  % Check length
  if numel(llh) > 1
    error('### The ''multinest'' function can work only with a single MFH object.')
  end
  
  % Get settings out of the plist
  Nlive       = find_core(pl, 'Nlive');
  tolerance   = find_core(pl, 'tol');
  prior       = find_core(pl, 'prior');
  verbose     = find_core(pl, 'verbose');
  p0          = find_core(pl, 'p0');
  DEBUG       = find_core(pl, 'DEBUG');
  opt         = find_core(pl, 'other options');
  
  % Check some inputs
  if isempty(p0)
    error('### Please input a pest object ''P0'' containing the parameter names and yunits...')
  end
  if isempty(Nlive)
    error('### Please define the number of live points ''NLIVE''...')
  end
  
  % Prepare the mfh object
  logL = MCMC.preprocessMFH(p0, llh);
  
  % called nested sampling routine
  [logZ, nest_samples, post_samples] = nested_sampler(Nlive, tolerance, logL, prior, verbose, DEBUG, opt{:});
  
  y  = mean(post_samples(:,1:numel(p0.names)));
  cv = cov(post_samples(:,1:numel(p0.names)));
  
  % Get the results
  p = pest(y);
  % set parameter names
  p.setNames(p0.names);
  % Set Yunits
  p.setYunits(p0.yunits);
  
  % Add statistical info
  p.setCov(cv);
  p.setCorr(utils.math.cov2corr(cv));
  
  p.setDy(sqrt(diag(cv)));
  % Filling the first 3 columns with zeroes for easier plotting
  p.setChain([post_samples(:,numel(p0.names)+1:end), zeros(size(post_samples,1), 1), post_samples(:,1:numel(p0.names))]);
  
  % Save info to procinfo plist
  p.setProcinfo(plist('nest_samples', nest_samples,...
                      'logZ',         logZ));
  
	% Set dof
  p.setDof();
  % Set chi2
  p.setChi2();
  % Set Name
  p.setName(sprintf('multinest(%s)',llh.name));
  % Set history
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', 'None', []);
  p.addHistory(ii, pl, mfh_invars, [mfh_in.hist]);  
  
  % create output object
  varargout{1} = p;
  
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
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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

  pl = plist();
  
  p = param({'p0','A pest object containing information about the parameters (parameter names and units).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'verbose','True-False flag for printing information on screen.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'debug','True-False flag for debuging purposes.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'Nlive','The number of live points for the Nested Sampling algorithm'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'tol','The tolerance value for the stoping criteria'}, paramValue.DOUBLE_VALUE(1e-3));
  pl.append(p);
  
  p = param({'prior','The prior densities of the parameters. See example for usage. Currently only handles Gaussian and Uniform priors. '}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'extraparams','TBD'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'other options','A cell array of other specialised options to be passed to the algorithm. For more information check the Matlab Multinest examples.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
end

% END