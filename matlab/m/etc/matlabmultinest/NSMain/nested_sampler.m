function [logZ, nest_samples, post_samples] = nested_sampler(Nlive, tolerance, likelihood, prior, verbose, DEBUG, varargin)


% function [logZ, nest_samples, post_samples] = nested_sampler(data, ...
%           Nlive, Nmcmc, tolerance, likelihood, model, prior, extraparams)
%
% This function performs nested sampling of the likelihood function from
% the given prior (given a set of data, a model, and a set of extra model
% parameters).
%
% By default the algorithm will draw new samples from a set of bounding
% ellipsoids constructed using the MultiNest algorithm for partitioning
% live points. However, if the optional 'Nmcmc' argument is set and
% Nmcmc > 0, new samples will be drawn from a proposal using an MCMC. This
% method is based on that of Veitch & Vecchio. For both methods the
% sampling will stop once the tolerance critereon has been reached.
%
% The likelihood should be the function handle of a likelihood function to
% use. This should return the log likelihood of the model parameters given
% the data.
%
% The model should be the function handle of the model function to be
% passed to the likelihood function.
%
% The prior should be a cell array with each cell containing five values:
%   parameter name (string)
%   prior type (string) e.g. 'uniform', 'gaussian' of 'jeffreys'
%   minimum value (for uniform prior), or mean value (for Gaussian prior)
%   maximum value (for uniform prior), or width (for Gaussian prior)
%   parameter behaviour (string):
%       'reflect' - if the parameters reflect off the boundaries
%       'cyclic'  - if the parameter space is cyclic
%       'fixed'   - if the parameters have fixe boundaries
%       ''        - for gaussian priors
%   e.g., prior = {'h0', 'uniform', 0, 1, 'reflect';
%                  'r', 'gaussian', 0, 5, '';
%                  'phi', 'uniform', 0, 2*pi, 'cyclic'};
%
% extraparams is a cell array of fixed extra parameters (in addition
% to those specified by prior) used by the model
% e.g.  extraparams = {'phi', 2;
%                      'x', 4};
%
% Optional arguments:
%  Set these via e.g. 'Nmcmc', 100
%   Nmcmc - if this is set then MultiNest will not be used as the sampling
%           algorithm. Instead an MCMC chain with this number of iterations
%           will be used to draw the number nested sample point.
%   Nsloppy - if this is set then during the MCMC the likelihood will only
%             be evaluted once every Nsloppy points rather than at every
%             iteration of the chain.
%   covfrac - the relative fraction of the iterations for which the MCMC
%             proposal distribution will be based on a Students-t
%             distribution defined by the covariance of the current live
%             points.
%   diffevfrac - the relative fraction of the iterations that will use
%                differential evolution to draw the new sample.
%   stretchfrac - the relative fraction of the iterations that will use the
%                 affine invariant ensemble stretch method for drawing a
%                 new sample
%   walkfrac - the relative fraction of the iterations that will use the
%              affine invariant ensemble walk method for drawing a new
%              sample
%   propscale - the scaling factor for the covariance matrix used by the
%               'covfrac' Students-t distribution proposal. This defaults
%               to 0.1.
%
% E.g. if covfrac = 10 then diffevfrac = 5 the Students-t proposal will be
% used 2/3s of the time and differential evolution 1/3. The default is to
% use the affine invariant samplers with the stretch move 75% of the time
% and the walk move 25% of the time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Nmcmc       = 0;
  Nsloppy     = 0;
  covfrac     = 0;
  diffevfrac  = 0;
  walkfrac    = 25;
  stretchfrac = 75;
  propscale   = 0.1;
  
  % get optional input arguments
  optargin = size(varargin,2);
  
  % get optional arguments
  if optargin > 1
    for ii = 1:2:optargin
      if strcmpi(varargin{ii}, 'Nmcmc') % number of MCMC samples
        if ~isempty(varargin{ii+1})
          if varargin{ii+1} < 1
            fprintf(1, 'Using MultiNest algorithm\n');
          else
            Nmcmc = varargin{ii+1};
          end
        end
      elseif strcmpi(varargin{ii}, 'Nsloppy') % number of burn in samples
        if ~isempty(varargin{ii+1})
          if varargin{ii+1} < 0
            fprintf(1, 'Number of \"sloppy\" samples is silly. Setting to zero\n');
          else
            Nsloppy = varargin{ii+1};
          end
        end
      elseif strcmpi(varargin{ii}, 'covfrac') % fraction of MCMC iterations using Students't proposal
        if varargin{ii+1} > 0
          covfrac = varargin{ii+1};
        end
      elseif strcmpi(varargin{ii}, 'diffevfrac') % fraction of MCMC iterations using differential evolution
        if varargin{ii+1} > 0
          diffevfrac = varargin{ii+1};
        end
      elseif strcmpi(varargin{ii}, 'walkfrac') % fraction of MCMC iterations using walk move
        if varargin{ii+1} >= 0
          walkfrac = varargin{ii+1};
        end
      elseif strcmpi(varargin{ii}, 'stretchfrac') % fraction of MCMC iterations using stretch move
        if varargin{ii+1} >= 0
          stretchfrac = varargin{ii+1};
        end
      elseif strcmpi(varargin{ii}, 'propscale') % the scaling factor for the covariance matrix
        if varargin{ii+1} > 0
          propscale = varargin{ii+1};
        end
      end
    end
  end

  % get the number of parameters from the prior array
  D = size(prior,1);
  
  % draw the set of initial live points from the prior
  livepoints = zeros(Nlive, D);
  
  for ii=1:D
    priortype = char(prior(ii,2));
    p3        = cell2mat(prior(ii,3));
    p4        = cell2mat(prior(ii,4));
    
    % currently only handles uniform or Gaussian priors
    if strcmp(priortype, 'uniform')
      livepoints(:,ii) = p3 + (p4-p3)*rand(Nlive,1);
    elseif strcmp(priortype, 'gaussian')
      livepoints(:,ii) = p3 + p4*randn(Nlive,1);
    elseif strcmp(priortype, 'jeffreys')
      % uniform in log space
      livepoints(:,ii) = 10.^(log10(p3) + (log10(p4)-log10(p3))*rand(Nlive,1));
    end
  end
  
  % check whether likelihood is a function handle, or a string that is a
  % function name
  if ischar(likelihood)
    flike = str2func(likelihood);
  elseif isa(likelihood, 'function_handle')
    flike = likelihood;
  else
    error('Error... Expecting a model function!');
  end
  
  % calculate the log likelihood of all the live points
  logL = zeros(Nlive,1);
  
  for ii=1:Nlive
    parvals  = livepoints(ii,:);
    logL(ii) = flike(parvals);
  end
  
  % Check if any values are NaNs or Infs
  if any(isnan(logL)) || any(isinf(logL))
    warning('### Some of the calculated initial values are NaNs or Infs. Please check the model or loglikelihood function...')
  end
  
  % now scale the parameters, so that uniform parameters range from 0->1,
  % and Gaussian parameters have a mean of zero and unit standard deviation
  for ii=1:Nlive
    livepoints(ii,:) = scale_parameters(prior, livepoints(ii,:));
  end
  
  % initial tolerance
  tol = inf;
  
  % initial width of prior volume (from X_0=1 to X_1=exp(-1/N))
  logw = log(1 - exp(-1/Nlive));
  
  % initial log evidence (Z=0)
  logZ = -inf;
  
  % initial information
  H = 0;
  
  % initialize array of samples for posterior
  nest_samples = zeros(1,D+1);
  
  %%%%%%%%%%%%%%%
  % some initial values if MultiNest sampling is used
  h  = 1.1; % h values from bottom of p. 1605 of Feroz and Hobson
  FS = h;   % start FS at h, so ellipsoidal partitioning is done first time
  K  = 1;   % start with one cluster of live points
  
  % get maximum likelihood
  logLmax = max(logL);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % initialize iteration counter
  jj = 1;
  
  %figure;
  
  % MAIN LOOP
  while tol > tolerance || jj <= Nlive
    
    % expected value of true remaining prior volume X
    VS = exp(-jj/Nlive);
    
    % find minimum of likelihoods
    [logLmin, idx] = min(logL);
    
    % set the sample to the minimum value
    nest_samples(jj,:) = [livepoints(idx, :) logLmin];
    
    % get the log weight (Wt = L*w)
    logWt = logLmin + logw;
    
    % save old evidence and information
    logZold = logZ;
    Hold = H;
    
    % update evidence, information, and width
    logZ = logplus(logZ, logWt);
    H = exp(logWt - logZ)*logLmin + ...
      exp(logZold - logZ)*(Hold + logZold) - logZ;
    %logw = logw - logt(Nlive);
    logw = logw - 1/Nlive;
      
    if Nmcmc > 0

        % do MCMC nested sampling

        % get the Cholesky decomposed covariance of the live points
        % (do every 100th iteration - CAN CHANGE THIS IF REQUIRED)
        if mod(jj-1, 100) == 0
            % NOTE that for numbers of parameters >~10 covariances are often
            % not positive definite and cholcov will have "problems".
            %cholmat = cholcov(propscale*cov(livepoints));

            % use modified Cholesky decomposition, which works even for
            % matrices that are not quite positive definite
            % from http://infohost.nmt.edu/~borchers/ldlt.html
            % (via http://stats.stackexchange.com/questions/6364
            % /making-square-root-of-covariance-matrix-positive-definite-matlab
            cv = cov(livepoints);
            [l, d] = mchol(propscale*cv);
            cholmat = l.'*sqrt(d);

            %plot3(livepoints(:,1), livepoints(:,2), livepoints(:,3), 'r.');
            %drawnow();
        end

        % draw a new sample using mcmc algorithm
        [livepoints(idx, :), logL(idx)] = draw_mcmc(livepoints, cholmat, ...
              logLmin, prior, flike, Nmcmc, Nsloppy, ...
              covfrac, diffevfrac, walkfrac, stretchfrac);

    else
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % do MultiNest nested sampling

      % separate out ellipsoids
      if FS >= h
        % NOTE: THIS CODE IS GUARANTEED TO RUN THE 1ST TIME THROUGH
        % calculate optimal ellipsoids
        [Bs, mus, VEs, ns] = optimal_ellipsoids(livepoints, VS, DEBUG);
        K                  = length(VEs); % number of ellipsoids (subclusters)

      else
        % simply rescale the bounding ellipsoids
        for kk=1:K
          scalefac = max([1 (exp(-(jj+1)/Nlive)*ns(kk)/Nlive)/VEs(kk)]);

          % scale bounding matrix and volume
          if scalefac ~= 1
            Bs((kk-1)*D+1:kk*D,:) = Bs((kk-1)*D+1:kk*D,:)*scalefac^(2/D);
            VEs(kk) = scalefac*VEs(kk);
          end
        end

      end

      % calculate ratio of volumes (FS>=1) and cumulative fractional volume
      Vtot    = sum(VEs);
      FS      = Vtot/VS;
      fracvol = cumsum(VEs)/Vtot;

      % draw a new sample using multinest algorithm
      [livepoints(idx, :), logL(idx)] = draw_multinest(fracvol, Bs, mus, logLmin, prior, flike, DEBUG);
      
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % update maximum likelihood if appropriate
    if logL(idx) > logLmax
      logLmax = logL(idx);
    end
    
    % work out tolerance for stopping criterion
    tol = logplus(logZ, logLmax - (jj/Nlive)) - logZ;
    
    % display progress (optional)
    if verbose
      fprintf(1, 'log(Z): %.5e, tol = %.5e, K = %d, iteration = %d\n', logZ, tol, K, jj);
    end
    
    % update counter
    jj = jj+1;
    
  end
  
  % sort the remaining points (in order of likelihood) and add them on to
  % the evidence
  [logL_sorted, isort] = sort(logL);
  livepoints_sorted = livepoints(isort, :);
  
  for ii=1:Nlive
    logZ = logplus(logZ, logL_sorted(ii) + logw);
  end
  
  % append the additional livepoints to the nested samples
  nest_samples = [nest_samples; livepoints_sorted logL_sorted];
  
  % rescale the samples back to their true ranges
  for ii=1:length(nest_samples)
    nest_samples(ii,1:end-1) = ...
      rescale_parameters(prior, nest_samples(ii,1:end-1));
  end
  
  % convert nested samples into posterior samples - nest2pos assumes that the
  % final column in the sample chain is the log likelihood
  post_samples = nest2pos(nest_samples, Nlive);
  
return
