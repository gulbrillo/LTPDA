%--------------------------------------------------------------------------
% Sanity checks and utils for the MH algorithm
%--------------------------------------------------------------------------
function [xo, cvar, jumps, bounds, decision, proposalsamp, issymmetric, Tc, proposalpdf, yunits, param, ADAPT] = mhutils(pl)

  proposalsamp = find(pl, 'proposal sampler');
  jumps        = find(pl, 'jumps');
  xo           = find(pl, 'x0');
  loga         = find(pl, 'loga');
  cvarIn       = find(pl, 'cov');
  rnge         = find(pl, 'range');
  Tc           = find(pl, 'Tc');
  param        = find(pl, 'FitParams');
  Nsamples     = find(pl, 'Nsamples');
  prior        = find(pl, 'prior');
  proposalpdf  = find(pl, 'proposal pdf');
  ADAPT        = find(pl, 'adaptive proposal');
      
  % check input covariance matrix    
  if isa(cvarIn, 'ao')
    cvar = double(cvarIn);
  elseif isnumeric(cvarIn)
    cvar = cvarIn;
  else
    error('### Covariance matrix must be either a pure numerical matrix, either an AO.');
  end
  
  % Scale covariance?
  if pl.find('scale cov')
    cvar = (numel(double(xo))^(-1/2))*cvar;
  end
  
  % check 'jumps' coefficients
  if isempty(jumps)
    jumps = ones(1, 4);
  end
  
  % Check if isempty the# of samples
  if isempty(Nsamples) 
    error('### Please check inputs. Filed ''N'' is necessary...')
  end
  
  % check if basic inputs are provided
  if ~isa(xo, 'pest')
    if isempty(param) || isempty(xo) 
     error('### Please check inputs. Fileds ''FitParams'' and ''x0'' are necessary.')
    end
  else
    param = xo.names;
  end
  
  % check prior densities
  if ~isa(prior, 'mfh') && ~isempty(prior) 
    error('### Please check inputs. The ''prior'' must be a MFH object.')
  end
  
  % check for ranges, otherwise fill it.
  if isempty(rnge)
    [rnge{1:numel(xo)}] = deal([-inf inf]);
  end
  
  % Check if AO or PEST object
  if isa(xo, 'pest') || isa(xo, 'ao')
    yunits = [xo.yunits];
  else
    yunits = {};
  end
  
  % convert to double and check dimensions
  xo = double(xo);
  if iscolumn(xo)
    xo = xo.';
  end
  
  % check the bounds
  if iscell(rnge) && numel(xo) == numel(rnge) && numel(param) == numel(xo)
    % Get range for parameters
    bounds = zeros(2,numel(param));
    for i = 1:numel(param)
      bounds(:,i) = rnge{i};
    end
  elseif isnumeric(rnge) && numel(xo) == size(rnge,2)
    bounds = rnge;
  else
    error('### Please check inputs. The elements of ''x0'' and ''ranges'' and ''Fitparams'' are not equal.')
  end
  
  % check if input parameters are out of bounds
  for ii = 1:numel(xo)
    if ((xo(ii) < bounds(1,ii)) || (xo(ii) > bounds(2,ii)))
      
      warning('LTPDA:mcmc', ['#### Parameter ' param{ii} ' is out of bounds!!! ' ...
        'Will pick a random value between the ranges specified.'])
      
      xo(ii) = bounds(1,ii) + (bounds(2,ii)-bounds(1,ii)).*rand(1,1);
    end
  end
  
  if loga 
    decision = @MCMC.logDecision;
  else
    decision = @MCMC.decision;
  end
  
  % check adaptive, set to false if not given
  if isempty(ADAPT)
    ADAPT = false;
  end
  
  % check proposal sampler. If empty use the multivariate Normal
  if isempty(proposalsamp)
    proposalsamp = @MCMC.drawSample;
  else
    proposalsamp = MCMC.preprocessMFH(xo, proposalsamp);
  end
  
  % If a proposal PDF is entered, it's assumed that 
  % it's not symmetric. 
  if ~isempty(proposalpdf) 
    proposalpdf  = MCMC.preprocessMFH(xo, proposalpdf);
    issymmetric = false;
  else
    issymmetric = true;
  end
  
  % Check heating index input
  if ~isempty(Tc)
    if ~(numel(Tc) == 2 || numel(Tc) == 3)
      error('### The ''TC'' index denotes the heating profile and by extention the adaptive proposal profile. It should be a [1x2] or [1x3] numerical vector...')
    end
    if ~ADAPT && numel(Tc)==2
      if Nsamples <= Tc(2)
        warning(['### The number of samples is less than Tc(2). The resulting PEST object '...
          'will not calculate automatically the statistics of the MCMC chains.'])
      elseif Tc(2) < Tc(1)
        warning('### The heating profile allows cooling down while heating is on, make sure whether this is really desired.')
      end
    end
    if (ADAPT && numel(Tc) ~= 3)
      warning('### The heating profile does not specify when to stop using adaptive proposals. A third Tc paramenter is required. The adaptive proposal scheme is not going to be performed...')
      Tc(3) = Tc(2);
    end
  else
    % Do not use heating and adaptive proposal schemes
    Tc = [0, 0, 0];
    % Throw a warning
    warning('### The heating profile parameter ''TC'' is empty. A heating and/or an adaptive proposal schemes are not going to be used...')
  end
  
  % Test the rescaling of covariance matrix
  vec = [1 jumps];
  for ii = 1:numel(vec)
    try
      chol(vec(ii)^2*cvar);
    catch Me
      error(['### The introduced covariance matrix might be not positive-definite when '...
             'rescaled during the burn-in and cooling down part of the sampling: Error: %s'], Me.message)
    end
  end
  
end