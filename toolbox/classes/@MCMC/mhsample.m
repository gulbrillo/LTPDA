% MHSAMPLE.M The Metropolis - Hastings algorithm
%
% The Metropolis-Hastings algorithm: Samples a given likelihood function.
%                  
%              Warning: The function mhsample does not performs sanity
%                       checks on the inputs. It assumes that the given
%                       data-sets are in frequency domain and correctly
%                       defined.
%
%    CALL:     b  = MCMC.mhsample(pl)
%
%  INPUTS:     pl - parameter list
%
% OUTPUTS:     b  - pest object contatining estimated information
%
%    NOTE:     The resulting pest object has its 'chain' field defined 
%              with the MCMC chains. The chain is a (# of samples x 2 +
%              # of parameters) numerical matrix. In the first column
%              the log-likelihood values are stored, while in the second
%              the SNR. The rest of them contain the parameter values.
%              If the log-likelihood is a 'mfh' object, due to 
%              Matlab limitations, the SNR column contains also the
%              log-likelihood values. 
%
% <a href="matlab:utils.helper.displayMethodInfo('MCMC', 'MCMC.mhsample')">Parameters Description</a>      
%
% MN/NK 2013
%
function varargout = mhsample(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### mhsample cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect plist
  pl = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl  = applyDefaults(getDefaultPlist, pl); 
  pl.getSetRandState();
  
  %%%%%%%%%%%%%%%%%%%%%%%%%  Gather inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  Nsamples      = find(pl, 'Nsamples');
  model         = find(pl, 'model');
  xi            = find(pl, 'heat');
  parplot       = find(pl, 'plot traces');
  search        = find(pl, 'search');
  prior         = find(pl, 'prior');
  anneal        = find(pl, 'anneal');
  dbg_info      = find(pl, 'debug');
  Fprint        = find(pl, 'Fprint');
  freqs         = find(pl, 'frequencies vector');
  plot_diag     = find(pl, 'plot diagnostics');
  inLogL        = find(pl, 'loglikelihood');
  print_diag    = find(pl, 'print diagnostics');
  writeToTXT    = find(pl, 'txt');
  p0            = find(pl, 'x0');
  covUpdate     = find(pl, 'cov update');
  adapt_factor  = find(pl, 'adaptive factor');
  
  % Sanity checks and utils
  [xo, cvar, jumps, bounds, decision, proposalsamp, issymmetric, Tc, proposalpdf, yunits, param, adaptive] = MCMC.mhutils(pl); 
  
  % Initialize
  [oldacc, ...
   oldrej, ...
   oldsamples, ...
   loglkexp2, ...
   smpl, smplr, ...
   all_param_names, ...
   ratio, ...
   plotvec, ...
   lp, ...
   p1, p2, ...
   prior,...
   data, ...
   Nexp, ...
   dof,...
   freqs] = initialize(xo, Nsamples, param, Fprint, parplot, prior, freqs, inLogL, pl);
  
  %%%%%%%%%%%%%%%%%%%  Define the log-likelihood function  %%%%%%%%%%%%%%%%
  
  loglikelihood = MCMC.defineLogLikelihood(xo, model, data, param, lp, inLogL, Nexp, freqs, pl);
  
  % Compute likelihood at x0, initialize
  [loglk1, snr1, loglkexp1] = loglikelihood(xo);
  
  smpl(1,:)      = [loglk1*p1 loglk1 snr1 xo];
  smplr(1,:)     = [loglk1*p2 loglk1 snr1 1 xo];
  nacc           = 1;
  samples        = 1;
  nrej           = 0;
  hjump          = 0;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Main Loop  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  utils.helper.msg(msg.IMPORTANT, '\n * Starting Monte Carlo sampling ...', mfilename('class'), mfilename);
  
  while (samples < Nsamples)
    
    % Sample new point on the parameter space
    [xn, hjump, cvar] = MCMC.jump(xo, cvar, hjump, jumps, samples, search, Tc, proposalsamp, adaptive, covUpdate, smpl, adapt_factor);
    
    % compute prior probability 
    if ~isempty(prior)
      p2 = prior(xn);
    end
    
    % Check if out of limits
    if (any(xn < bounds(1,:)) || any(xn > bounds(2,:)))
      
      loglk2 = -inf;
      snr2   = 0;
      beta   = inf;
      
    else
      
      % Compute log-likelihood at proposed point
      [loglk2, snr2, loglkexp2]  = loglikelihood(xn);
      
      % Compute annealing factor
      beta = MCMC.computeBeta(samples,Tc,anneal,xi);
      
    end 
       
    % Decide if sample is accepted or not
    [logr, answ, post] = decision(loglk1, loglk2, beta, proposalpdf, [p1 p2], issymmetric);
    
    if answ
      
      xo               = xn; 
      nacc             = nacc + 1;
      samples          = samples + 1;
      smpl(samples,:)  = [post(2) loglk2 snr2 xn];
      p1               = p2;
      
      % Keep the rejected proposals also.
      smplr(samples,:) = [post(2) loglk2 snr2 1 xn];
      loglk1           = loglk2;
      snr1             = snr2;
      
      % Answer = accepted
      me = 'acc';
      
    else
      
      nrej             = nrej + 1;
      samples          = samples + 1;
      smpl(samples,:)  = [post(1) loglk1 snr1 xo];
      
      % Keep the rejected proposals also.
      smplr(samples,:) = [post(1) loglk1 snr2 0 xn];
      
      % Answer = rejected
      me = 'rej';    
      
    end
    
    % Print to screen
    if dbg_info
      printMe(me, loglk1, loglk2, loglkexp1, loglkexp2, beta, logr, snr1, snr2, dof)
    end
    
    % Display and save
    [ratio, oldacc, oldrej, oldsamples] = printinfo(Nsamples, samples, Fprint, oldsamples, oldacc, oldrej, nrej, parplot, plotvec,...
                                                    nacc, ratio, param, smpl, smplr, all_param_names, writeToTXT);
    
  end % END of main loop
  
  fprintf('-------------     Finalising    -------------\n');
  
  % Statistics of the Chain.
  [mn, cv, cr, PSRE, T, X, KStest] = MCMC.processChain(smpl, Tc, print_diag, plot_diag);
  
  % Print info on screen
  totalAccRate = num2str(100*sum(smplr(Tc(end)+1:end,4))/numel(smplr(Tc(end)+1:end,4)), '%5.2f\n');
  fprintf('* Total acceptance rate:                : = %s %% \n\n', totalAccRate)

  % Print message
  fprintf('* Generating pest object ... \n') 
  
  % Create pest output
  if isa(p0, 'pest')
    p = copy(p0, 1);
    p.setY(mn);
  else
    % build pest
    p = pest(mn);
    % set parameter names
    p.setNames(param{:});
    % Set Yunits
    p.setYunits(yunits);
  end
  
  % Add statistical info
  p.setCov(cv);
  p.setCorr(cr);
  
  p.setDy(sqrt(diag(cv)));
  p.setChain(smpl);
  
  % Save info to procinfo plist
  p.setProcinfo(plist('smplr',      smplr,...
                      'acc ratio',  ratio, ...
                      'PSRE',       PSRE,...
                      'corr',       T,...
                      'Yu-Mykland', X,...
                      'KStest',     KStest));
  
	% Set dof
  p.setDof(dof);
  % Set chi2
  p.setChi2(abs(2*loglikelihood(mn))/(dof-numel(mn)));
  % Set Name
  p.setName(sprintf('MCMC(%s)',inLogL.name));
  % Set models
  p.setModels(model);
  % Set history
  p = addHistory(p,getInfo('None'), pl, [], []);  
  % Set output
  varargout{1} = p;
  % Print in table
  table(p);
  
end

%--------------------------------------------------------------------------
% Initialize
%--------------------------------------------------------------------------
function [oldacc, oldrej, oldsamples, ...
          loglkexp2, smpl, smplr, ...
          all_param_names, ratio, plotvec, ...
          lp, p1, p2, prior, data, Nexp, dof, freqs] = initialize(xo, Nsamples, param, Fprint, parplot, prior, freqs, inLogL, pl)

  % Init
  oldacc     = 0;
  oldrej     = 0;
  oldsamples = 0;
  loglkexp2  = 0;
  
  %Extract from the plist
  fin       = find(pl, 'input');
  fout      = find(pl, 'output');
  S         = find(pl, 'noise');
  logparams = find(pl, 'log parameters');
  loga      = find(pl, 'loga');
  
  % In the first 3 columns of the chains, the log-posterior, the log-likelihood
  % and the current SNR are stored.
  smpl            = zeros(Nsamples, numel(param)+3);
  smplr           = zeros(Nsamples, numel(param)+4);
  all_param_names = cell(1,numel(param)+3);
  ratio           = zeros(floor(Nsamples/Fprint),1);

  % Handle for figures. Do not plot over existing figures.
  plotvec = zeros(1, ceil((numel(param)+3)/4));
  if parplot
    for oo = 1:numel(plotvec)
      figure;
      plotvec(oo) = get(0,'CurrentFigure');
    end
    all_param_names{1} = 'LogPosterior';
    all_param_names{2} = 'LogLikelihood';
    all_param_names{3} = 'SNR';
    for ii = 1:numel(param)
      all_param_names{ii+3} = param{ii};
    end
  end     
  
  % Index of logarithm of parameters
  lp = zeros(1,numel(param));
  if ~isempty(logparams)
    for oo = 1:numel(param)
      if any(strcmp(param{oo},logparams))
        lp(oo) = 1;
      end
    end
  end
  
  % Compute prior for the initial sample of the chain 
  if isempty(prior) && loga
    p1 = 1;
    p2 = 1;
  elseif isempty(prior) && ~loga
    p1 = 0;
    p2 = 0;
  elseif isempty(prior) && loga
    prior = MCMC.preprocessMFH(xo, prior);
    p1    = prior(xo);
    p2    = 1;
  else
    prior = MCMC.preprocessMFH(xo, prior);
    p1    = prior(xo);
    p2    = 0;
  end 
  
  % Store the data into structure arrays & compute DOF 
  if ~isempty(fout) && ~isempty(fin) &&  ~isempty(S) % SSM case
    data = MCMC.ao2strucArrays(plist('in',fin,'out',fout,'S',S,'Nexp',size(S,3)));
    % Get # of experiments
    Nexp  = numel(data);
    dof = zeros(1, Nexp);
    % Get DoF
    for k = 1:Nexp
      dof(k) = numel(freqs{k}) - numel(param);
    end
    dof = sum(dof);
  elseif ~isempty(inLogL.procinfo) && (~isempty(inLogL.procinfo.find('fft_signals')) || ~isempty(inLogL.procinfo.find('model')))
    
    num    = inLogL.procinfo.find('fft_signals');
    ISFREQ = true;
    if isempty(num)
      num    = inLogL.procinfo.find('model');
      ISFREQ = false;
    end
    % Get DoF
    switch class(num)
      case 'mfh'
         Nexp = numel(num.index(1,:));
         dof  = zeros(1, Nexp);
        for k = 1:Nexp
          data   = num(1,k).eval(xo);
          if ISFREQ
            dof(k) = 2*data.len;
          else
            dof(k) = data.len;
          end
        end
      case 'ao'
         Nexp = numel(num(1,:));
         dof  = zeros(1, Nexp);
        for k = 1:Nexp
          data   = copy(num(1,k));
          dof(k) = data.len;
        end
    end
    dof = sum(dof);
  else % set them to unity
    Nexp  = 1;
    dof   = 1;
    freqs = {1};
    data  = 1;
  end

end

%--------------------------------------------------------------------------
% normLikelihood to the Ndata points
%--------------------------------------------------------------------------
function nlogL = normLikelihood(logLexp, dof)

  nlogL = sum(logLexp./dof);

end

%--------------------------------------------------------------------------
% Function to to report on screen or plot the traces
%--------------------------------------------------------------------------
function [ratio, oldacc, oldrej, oldsamples] = printinfo(Nsamples, samples, Fprint, oldsamples, oldacc, oldrej, nrej, parplot, plotvec, ...
                                                         nacc, ratio, param, smpl, smplr, all_param_names, writeToTXT)

  if(mod(samples,Fprint) == 0 && (samples) ~= (oldsamples))

    updacc = nacc-oldacc;
    updrej = nrej-oldrej;

    ratio(samples/Fprint,:) = updacc/(updacc+updrej);
    xn = mean(smpl((floor(samples/Fprint)-1)*Fprint+1:samples,4:end));
    sn = std(smpl((floor(samples/Fprint)-1)*Fprint+1:samples,4:end));
    
    txt = {};
    
    nParams = numel(smpl(1,4:end));
    
    banner = sprintf('------------- Parameters Update -------------');
    txt = [txt; {banner}];
    
    % Contents
    txt = [txt; {' '}];
    for pp=1:nParams
      txt = [txt; {sprintf('     %s', getParameterString(param, xn, sn, pp))}];
    end
    txt = [txt; {' '}];
    txt = [txt; {sprintf('  Posterior: %s', utils.helper.val2str(smplr(samples, 1)))}];
    txt = [txt; {sprintf('    Samples: %s of %s', utils.helper.val2str(samples), utils.helper.val2str(Nsamples))}];
    txt = [txt; {sprintf('  acc. rate: %s %%', utils.helper.val2str(round(100*(updacc/(updacc+updrej)))))}];
    %txt = [txt; {' '}];
    banner_end(1:length(banner)) = '.';
    txt = [txt; {banner_end}];
    txt = [txt; {' '}];
    
    % Display
    for jj=1:length(txt)
      disp(txt{jj});
    end

    % Update
    oldacc     = nacc;
    oldrej     = nrej;
    oldsamples = samples;

    if writeToTXT
      save('acceptance.txt','ratio','-ASCII')
    end

    % Plot Traces
    if  parplot        
      utils.helper.plotTraces(plotvec, numel(all_param_names), smpl(1:samples,:), all_param_names, xn, 'r', 'k');
      drawnow;
    end
  end
    
end

%--------------------------------------------------------------------------
% Function to print Info
%--------------------------------------------------------------------------
function printMe(res, loglk1, loglk2, loglkexp1, loglkexp2, beta, logr, snr1, snr2, dof)
  
  fprintf('%s.\t loglik: %d -> %d beta: %d  ratio: %d  SNR: %d -> %d  loglik/data: %d -> %d  \n', ...
                res, loglk1, loglk2, beta, logr, snr1, snr2, normLikelihood(loglkexp1,dof), normLikelihood(loglkexp2,dof));

end

%--------------------------------------------------------------------------
% Sub-Function to get string of parameter value
%--------------------------------------------------------------------------
function s = getParameterString(param, xn, sn, idx)
  
  maxParamName = max(cellfun(@length, param));
  if numel(param) >= idx
    s = sprintf('%1$*2$s:',param{idx}, maxParamName);
  else
    s = sprintf('%1$*2$s:', '???', maxParamName);
  end
  
  % Add Value for the parameter if exists
  if numel(xn) >= idx
    s = sprintf('%s %15.8g', s, xn(idx));
  end
  % Add Error for the parameter if exists
  if numel(sn) >= idx
    s = sprintf('%s +- %15.8g', s, sn(idx));
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
  
  % INNAMES
  p = param({'INNAMES','Input names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % OUTNAMES
  p = param({'OUTNAMES','Output names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % MODEL
  p = param({'MODEL',['Model to fit. It is more efficient of the model is enlightened before the fit. If ',...
                      'you use the MCMC.mhsample fuction externaly, consider pre-processing the model with the ',...
                      'finction MCMC.preprocessModel().']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % DIFF MODEL
  p = param({'DIFF MODEL',['Model to use for the update of the covariance matrix during the search phase. It should ',...
                           'be an unprocessed version of the model to fit.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % FITPARAMS
  p = param({'FITPARAMS','A cell array of evaluated parameters.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % INPUT
  p = param({'INPUT','An AO array/matrix of input signals.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % OUTPUT
  p = param({'OUTPUT','An AO array/matrix of output signals.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % N
  p = param({'NSAMPLES','number of samples of the chain.'}, paramValue.DOUBLE_VALUE(1000));
  pl.append(p);
  
  % SIGMA
  p = param({'COV','covariance of the gaussian jumping distribution.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % SCALE COV
  p = param({'SCALE COV','True-False flag to scale the covariance matrix with N_pars^(-1/2) for a more suitable proposal distribution.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % NOISE
  p = param({'NOISE',['A matrix array of noise spectrum (PSD) used to compute the likelihood. ' ...
                      'It is possible to input just a scale matrix, containing the desirable weights.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % FITPARAMS
  p = param({'LOGLIKELIHOOD','A log-likelihood function. Must be a ''mhf'' LTPDA object.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % RANGE
  p = param({'RANGE',['Range where the parameteters are sampled. They are used as uniform priors if no prior knowledge '...
                      'of the parameters is present. For example, for a two parameter problem [x1, x2], the ranges are '...
                      'set as r = {[min_x1 max_x1], [min_x2 max_x2]}. If the input inital values x0 are outside those limits, '...
                      'a random parameteer vector from r will be chosen.']},  paramValue.EMPTY_CELL);
  pl.append(p);
  
  % SEARCH
  p = param({'SEARCH','Set to true to use bigger jumps in parameter space during annealing and cool down.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % PROPOSAL SAMPLER
  p = param({'PROPOSAL SAMPLER','Set the proposal PDF to sample from. If left empty the multivariate Gaussian is used.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % PROPOSAL PDF
  p = param({'PROPOSAL PDF',['Input the proposal PDF. This is needed when the proposal PDF is not symmetric.',...
                             'If this field is empty, a symmetric PDF is assumed. Check help for details.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % heat
  p = param({'HEAT','The heat index flattening likelihood surface during annealing.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % TC
  p = param({'TC','An array of three values [i, j, k], setting the i-th and j-th sample for the cooling down. The k value is used for the adaptive proposal scheme. The proposal will be optimised up to the k-th sample of the chain.'}, paramValue.DOUBLE_VALUE([0 0 0]));
  pl.append(p);
  
  % X0
  p = param({'X0','The proposed initial values.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('paramValues');
  p.addAlternativeKey('p0');
  pl.append(p);
  
  % JUMPS
  p = param({'JUMPS','An array of four numbers setting the rescaling of the covariance matrix during the search phase.',...
    'The first value is the one applied by default, the following thhree apply just when the chain sample is',...
    'mod(10), mod(25) and mod(100) respectively.'}, paramValue.DOUBLE_VALUE([2 10 1e3 1e4]));
  pl.append(p);
  
  % PLOT TRACES
  p = param({'PLOT TRACES','True-False flag to plot the chain traces during the run. The figures are printed every ''FPRINT'' samples.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % PLOT DIAGNOSTICS
  p = param({'PLOT DIAGNOSTICS','Set to true to plot diagnostigs at the end of the sampling.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % DEBUG
  p = param({'DEBUG','Set to true to get debug information of the MCMC process.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % PRINT DIAGNOTICS
  p = param({'PRINT DIAGNOSTICS','Set to true to print information of the statistics of the MCMC chains.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % PRINT FREQ
  p = param({'FPRINT',['Print progress on screen every ' ...
                      'specified numeber of samples.']}, paramValue.DOUBLE_VALUE(100));
  pl.append(p);
  
  % TXT
  p = param({'TXT',['Set to true to print the acceptance ratio to a txt file ' ...
                    'during the MH sampling.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % PRIOR
  p = param({'PRIOR','Must be an MFH object that calculates the prior probability at a given point.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % LOG-PARAMETERS
  p = param({'LOG PARAMETERS','Select the parameters to be treated in log scale.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % ANNEALING
  p = param({'ANNEAL',['Choose type of annealing during sampling. Default value is ',...
                       'simulated annealing. Choose "thermo" for annealing with a thermostat.',...
                       ' SNR is computed and if it is larger than a fixed value SNR0 (provided also in the plist), ',...
                       'then the chains are heated by a factor of (SNR(1)/SNR0)^2.']}, {1, {'simul','thermo'}, ...
                       paramValue.SINGLE});
  pl.append(p);
  
  % MODELFREQDEP
  p = param({'MODELFREQDEPENDENT','Set to true to use frequency dependent s models, set to false when using constant models'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % SNR0
  p = param({'SNR0','Fixed value for thermostated annealing.'},   {1, {200}, paramValue.OPTIONAL});
  pl.append(p);
  
  % FREQUENCIES VECTOR
  p = param({'FREQUENCIES VECTOR',['A vector of frequencies. Used for the update of the ' ...
                                   'Fisher Matrix during the MH sampling.']},   {1, {200}, paramValue.EMPTY_DOUBLE});
  pl.append(p);
  
  % DIFFSTEP
  p = plist({'DIFFSTEP','Numerical differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % NGRID
  p = plist({'NGRID','Number of points in the grid to compute the optimal differentiation step for ssm models'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % STEPRANGES
  p = plist({'STEPRANGES','An array with upper and lower values for the parameters ranges. To be used to compute the optimal differentiation step for ssm models.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % LOG(A)
  p = plist({'LOGA','True-False flag. Set to true when the logarithm of the likelihood is used.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % ADAPTIVE PROPOSAL
  p = param({'ADAPTIVE PROPOSAL', 'True-False flag. Set to true if you want to use adaptive proposals for the MCMC chain. Requires to set a third Tc profile parameter.'}, paramValue.TRUE_FALSE);
  p.addAlternativeKey('ADAPTIVE');
  pl.append(p);

  % ADAPTIVE PROPOSAL FACTOR (beta)
  p = param({'ADAPTIVE FACTOR', 'This factor has to be a small positive constant, and is applied to the adaptive proposal algorithm.'}, paramValue.DOUBLE_VALUE(1e-20));
  p.addAlternativeKey('FACTOR');
  pl.append(p);

  % COV UPDATE
  p = param({'COVARIANCE UPDATE', 'For the cases where the ''ADAPTIVE'' scheme is active, this key defines the number of samples after which the covariance matrix is updated up until TC(3). See plist key ''TC''.'}, paramValue.DOUBLE_VALUE(1e3));
  p.addAlternativeKey('COV UPDATE');
  pl.append(p);
  
  % support rebuild by allowing the rand_stream to be specified
  pl.append(plist.RAND_STREAM);
  
end

% END