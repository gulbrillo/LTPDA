% RJSAMPLE Reverse Jump MCMC sampling using the "Metropolized Carlin And Chib" Method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reverse Jump MCMC sampling using the "Metropolized Carlin And Chib" Method.
%
%              Warning: The function mhsample does not performs sanity
%                       checks on the inputs. It assumes that the given
%                       data-sets are in frequency domain and correctly
%                       defined.
%
% CALL:        p = rjsample(out, pl)
%
% INPUTS:      out     - analysis objects with measured outputs
%
%              pl      - parameter list
%
% OUTPUTS:     p       - pest object contatining estimated information
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'rjsample')">Parameters Description</a>
%
% N. Karnesis 27/09/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = rjsample(varargin)
        
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Method can not be used as a modifier
  if nargout == 0
    error('### rjsample cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs smodels and plists
  [aos_in, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl                  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl  = applyDefaults(getDefaultPlist, pl);
  
  % Copy input aos
  fout = copy(aos_in,1); 
  
  % Gather inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  Nsamples      = find_core(pl, 'N');
  Tc            = find_core(pl, 'Tc');
  models        = find_core(pl, 'models');
  cvarIn        = find_core(pl, 'cov');
  xi            = find_core(pl, 'heat');
  xoin          = find_core(pl, 'x0');
  jumps         = find_core(pl, 'jumps');
  param         = find_core(pl, 'FitParams');
  loglikelihood = find_core(pl, 'log-likelihood');
  outNames      = find_core(pl, 'outNames');
  inNames       = find_core(pl, 'inNames');
  parplot       = find_core(pl, 'plot BF');
  search        = find_core(pl, 'N');
  dbg_info      = find_core(pl, 'debug');
  Fprint        = find_core(pl, 'Fprint');
  fin           = find_core(pl, 'input');
  S             = find_core(pl, 'Scale matrix');
  %logD          = find_core(pl, 'logspace');
  logparams     = find_core(pl, 'log parameters');
  freqs         = find_core(pl, 'frequencies vector');
  mdlFreqDep    = find_core(pl, 'modelFreqDependent');
  outModel      = find_core(pl, 'outModel');
  inModel       = find_core(pl, 'inModel');
  limit         = find_core(pl, 'range');
  
  % Check inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if isempty(Nsamples) || isempty(param) || isempty(xoin) || isempty(limit)
   
   error(['### Please check inputs. Fileds ''FitParams'', '...
          ' ''x0'', ''range'' and  ''N'', are necessary.'])
  
  end
  
  nummodels = numel(models);
  
  covs      = cell(1,nummodels);
  for k = 1:nummodels
    % Get covariance values
    if isa(cvarIn{k}, 'ao')
      covs{k} = cvarIn{k}.y;
    elseif isnumeric(cvarIn{k})
      covs{k} = cvarIn{k};
    else
      error(['### Covariance matrices must be either a pure numerical matrices,'...
             'either AOs in a cell array.']);
    end
  end
  
  % Get # of models
  nummodels = numel(models(1,:));
  
  % List all the parameters
  [allparams maxnumpars numpars allnumparams] = listparams(param);
  
  % Construct pure numerical vector to contain xo
  xo = zeros(nummodels,maxnumpars);
  for k = 1:nummodels
    xo(k,1:numpars(k)) = xoin{k};
  end
  
  numfactors = 0;
  for gg = 1:(nummodels)
    for dd = gg+1:(nummodels)
      numfactors = numfactors + 1;
    end
  end
  
  % Creates a set of colors from the Winter colormap
  cmap_factors = winter(numfactors);  
  cmap_models  = winter(nummodels); 
  
  % Initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  summ       = 0;
  rejected   = 0;
  legen      = [];
  logp       = zeros(1,nummodels);
  Bxy        = cell(nummodels,nummodels);
  lklhds     = zeros(Nsamples,nummodels);
  chains     = zeros(Nsamples,maxnumpars,nummodels);
  mnacc      = zeros(Nsamples,nummodels);
  mnacc(1,:) = ones(1,nummodels);
  nacc       = 1;
  
  % Check for log-parameters
  lp = zeros(maxnumpars,nummodels);
  if ~isempty(logparams)
    for k = 1:nummodels
      for jj = 1:numel(param{k})
        if any(strcmp(param{k}{jj},logparams))
          lp(jj,k) = 1;
        end
      end
    end
  end
  
  % Get # of samples in data
  Ndata = len(fout(1,1));
  
  % Define log-likelihood  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if isempty(loglikelihood)
    
    utils.helper.msg(msg.IMPORTANT, 'Pre-processing the models ...', mfilename('class'), mfilename);
    
    pmodels(1:nummodels) = ssm(); 
    
    for k = 1:nummodels
      pmodels(1,k) = preprocessModel(models, freqs, mdlFreqDep, inNames, outNames);
    end
    
    utils.helper.msg(msg.IMPORTANT, 'Defining default log-likelihood functions ...', mfilename('class'), mfilename);
    
    Nexp = numel(fin(1,:));
      
    % Get the numerical matrices
    mats = ao2numMatrices(fout,plist('in',fin,'S',S,'Nexp',Nexp));

    fin     = mats{1};
    nfout   = mats{2};
    S       = mats{3};
    
    for k = 1:nummodels
      loglikelihood{k} = getLoglikelihood(fin,nfout,S,pmodels(1,k),param{k},freqs,lp(:,k)',inModel,outModel,inNames{k},outNames{k});
    end
    
  elseif ~iscell(loglikelihood)
    
    error(['### The functions to sample with the RJMCMC must be MATLAB function ' ...
           'handle objects contained in a cell array. Please check again.'])
         
  end
  
  % Get values for k = 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  for k = 1:nummodels 
    % Compute loglikelihood for starting model and values  
    [lklhds(1,k) ~] = loglikelihood{k}(xo(k,1:numpars(k)));
    chains(1,1:numpars(k),k) = xo(k,1:numpars(k));
    % Calculate prior densities (assumed uniform priors)
    logp(k) = logpriors(limit{k},lp(:,k)');
  end
  
  utils.helper.msg(msg.IMPORTANT, 'Starting Reversible Jump MCMC      ', mfilename('class'), mfilename);
  
  hjump = 0;

  % Initialize: choose starting model k == 1
  k = 1;
  % Compute loglikelihood for starting model and values      
  [loglk1mdl1 ~] = loglikelihood{k}(xo(k,1:numpars(k)));
  
  
  % Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  while(nacc<Nsamples)
     
    % Propose new point in the parameter space for model k
    [xn hjump] = propose(xo(k,1:numpars(k)),covs{k},search,Tc,jumps,hjump,nacc);
    
    % Check if out of limits
    if( any(xn < limit{k}(1,:)) || any(xn > limit{k}(2,:)))
      
      loglk2mdl1 = inf;
        
    else
      
      [loglk2mdl1 ~] = loglikelihood{k}(xn);
      
    end
    
    % Compute betta
    betta = computeBetta(nacc,Tc,xi);
    
    % Metropolis sampler -> In-model step 
    [xo x0 loglk1mdl1 loglk2mdl1 rj] = metropolis(k,betta,xn,xo,loglk1mdl1,loglk2mdl1,numpars);
    
    % Update parameters (dimension matching)
    if ~rj
      for gg = 1:nummodels
        xo(gg,1:numpars(gg)) = updateparams(param,numpars,xo,k,gg);
      end
    end
    
    % Fill chains
    % chains = updateparams(allparams,allnumparams,xo,k,gg);
    
    % Draw random integer to jump into model
    % (supposed equal probability to jump to any model, including the present one)
    k_new  = randi(nummodels,1);
        
    % Propose new point in new model k'
    xn_new = propose(xo(k_new,1:numpars(k_new)),covs{k_new},search,Tc,jumps,hjump,nacc);

    % Check if out of limits for new model
    if( any(xn_new < limit{k_new}(1,:)) || any(xn_new > limit{k_new}(2,:)))

        loglk2mdl2 = inf;
        
    else
       [loglk2mdl2 ~] = loglikelihood{k_new}(xn_new);
    end
    
    % Calculate proposal densities
    logq(1) = logprpsl(xo(k,1:numpars(k)),x0,covs{k});
    logq(2) = logprpsl(xn_new,xo(k_new,1:numpars(k_new)),covs{k_new});
    
    % Ratio (independent proposals => Jacobian = 1)
    logr = (loglk2mdl2 - loglk2mdl1 + logq(2) - logq(1) + logp(k_new) - logp(k));   
    
    % Decide if sample in new model is accepted or not %%%%%%%%%%%%%%%%%%%%
    if logr < 0
      
      xo(k_new,1:numpars(k_new)) = xn_new;  
      nacc                       = nacc+1;
      mnacc(nacc,:)              = mnacc(nacc-1,:);
      mnacc(nacc,k_new)          = mnacc(nacc-1,k_new) + 1;
      lklhds(nacc-1,k_new)       = loglk2mdl2; 
      
      chains(mnacc(nacc,k_new) -1,1:numpars(k_new),k_new) = xn_new;
      
      if (k ~= k_new); lklhds(nacc,k) = loglk2mdl1; end
      
      % Accept new model
      k = k_new;
      
      % Update parameters again
      for gg = 1:nummodels
        xo(gg,1:numpars(gg)) = updateparams(param,numpars,xo,k,gg);
      end
      
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('acc new k: %d   loglik: %d /data   ratio: %d    ',k_new,loglk2mdl2/Ndata,logr));
      end
      
    elseif rand(1) > (1 - exp(-logr))
      
      xo(k_new,1:numpars(k_new)) = xn_new;  
      nacc                       = nacc+1;
      mnacc(nacc,:)              = mnacc(nacc-1,:);
      mnacc(nacc,k_new)          = mnacc(nacc-1,k_new) + 1;
      lklhds(nacc-1,k_new)       = loglk2mdl2; 
      
      chains(mnacc(nacc,k_new) -1,1:numpars(k_new),k_new) = xn_new;
      
      if (k ~= k_new); lklhds(nacc,k) = loglk2mdl1; end
      
      % Accept new model
      k = k_new;
      
      % Update parameters again
      for gg = 1:nummodels
        xo(gg,1:numpars(gg)) = updateparams(param,numpars,xo,k,gg);
      end
      
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('acc new k: %d   loglik: %d /data   ratio: %d    ',k_new,loglk2mdl2/Ndata,logr));
      end
      
    elseif isnan(logr)
      
      rejected    = rejected + 1;
      if dbg_info
        utils.helper.msg(msg.IMPORTANT, sprintf('rejected: %d out of bounds    ',rejected));      
      end
      
    else
      
      nacc            = nacc+1;
      mnacc(nacc,:)   = mnacc(nacc-1,:);
      mnacc(nacc,k)   = mnacc(nacc-1,k) + 1;
      
      chains(mnacc(nacc,k) -1,1:numpars(k),k) = xo(k,1:numpars(k));
      
      if (k ~= k_new); lklhds(nacc,k_new) = loglk2mdl2; end
      
      % Printing on screen the correct things
      if rj
        
        lklhds(nacc,k) = loglk1mdl1;
        if dbg_info
          utils.helper.msg(msg.IMPORTANT, sprintf('acc old k: %d   loglik: %d  /data   ratio: %d    ',k,loglk1mdl1/Ndata,logr));
        end
        
      else
        
        lklhds(nacc,k) = loglk2mdl1;
        
        if (k ~= k_new); lklhds(nacc,k_new) = loglk2mdl2; end
        
        xo(k,1:numpars(k)) = xn;
        
        if dbg_info
          utils.helper.msg(msg.IMPORTANT, sprintf('acc old k: %d   loglik: %d /data   ratio: %d    ',k,loglk2mdl1/Ndata,logr));
        end
          
      end
       
    end 
    
    % Printing and Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    str = [];
    % Printing to screen the following: "acc(#_of_model): # of points in
    % model #_of_model" for ii = 1:nummodels
    if dbg_info
      for ii = 1:nummodels
        str = [str sprintf('acc%d: %d   ',ii,mnacc(nacc,ii))];
      end
      utils.helper.msg(msg.IMPORTANT, str);
    end
    
    % The handshake problem 
    for gg = 1:(nummodels)
      for dd = gg+1:(nummodels)
        % Calculate Bayes Factor 
        Bxy{gg,dd}(nacc,1) = mnacc(nacc,gg)/mnacc(nacc,dd);               
      end
    end
    
    % Plot Bayes factor
    if (parplot && (mod(summ,Fprint) == 0) && (nacc ~= 0))
      figure(1)
      nn = 1;
      for gg = 1:(nummodels)
        for dd = gg+1:(nummodels)
          legen = [legen ; sprintf('B%d%d',gg,dd)]; % legend
          plot(Bxy{gg,dd}(:,1),'Color',cmap_factors(nn,:)) 
          legend(legen)
          hold on
          nn = nn + 1;
        end 
      end
    hold off
    legen = [];
    end
    
    % Plot LogLikelihood for each model 
    if (parplot && (mod(summ,Fprint) == 0) && (nacc ~= 0)) 
      figure (2)
      nn = 1;
      for jj = 3:(nummodels+2)
        lklhds(lklhds==0) = nan;
        plot(lklhds(1:nacc,jj-2)/Ndata,'Color',cmap_models(nn,:)) 
        ylabel('Log-Likelihoods')
        legen = [legen ; sprintf('model%d',jj-2)]; % legend
        legend(legen)
        hold on
        nn = nn + 1;
      end
      hold off
      legen = [];
    end
   
    % Display and save
    if (mod(summ,Fprint) == 0) && (nacc ~= 2)
      str = [];
      utils.helper.msg(msg.IMPORTANT, sprintf('#### Number of samples collected so far: %d / %d samples.',nacc,Nsamples), mfilename('class'), mfilename);
      for ii = 1:nummodels
        str = [str sprintf('acc%d: %d   ',ii,mnacc(nacc,ii))];
      end
      utils.helper.msg(msg.IMPORTANT, ['#### ' str]);
    end
   
    % Sum of points (used for plotting mainly -> avoid repeated ploting). 
    summ = summ+1; 
  end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%EndOfMainLoop%
  
  % Create the output
  BayesFactor(1:numfactors) = ao();
  nn = 1;
  for gg = 1:(nummodels)
    for dd = gg+1:(nummodels)

      BayesFactor(nn) = ao(Bxy{gg,dd});
      
      BayesFactor(nn).setName(sprintf('B%d%d %s',gg,dd,' RJMCMC'));  
      BayesFactor(nn).procinfo = plist('Likelihoods', lklhds,...
                                       'chains',      chains);
      nn = nn + 1;                               
    end
  end
  
  output = {BayesFactor};
  varargout = output(1:nargout);
  
end

%--------------------------------------------------------------------------
%      Get Default log-likelihood function given the model format
%--------------------------------------------------------------------------
function logL = getLoglikelihood(fin,fout,S,model,param,freqs,lp,inModel,outModel,inNames,outNames)
  
  switch class(model)
    
    case 'matrix'
        
      logL = @(x) loglikelihood(model, x, fin, fout, S, param, lp, outModel);      
        
    case 'ssm'
 
      % Define bode plist for ssm models
      spl = plist('outputs',          outNames, ...
                  'inputs',           inNames, ...
                  'reorganize',       false,...
                  'numeric output',   false,...
                  'f',                freqs);
                
      % keep the ssm symbolic matrices
      Amats = model.amats;
      Bmats = model.bmats;
      Cmats = model.cmats;
      Dmats = model.dmats;          
        
      logL = @(x) loglikelihood(model,x,fin,fout,S,param,spl,lp,Amats,Bmats,Cmats,Dmats);
    
    case 'smodel'
      
      logL = @(x) loglikelihood(model,x, fin, fout, S, params, lp);
      
    otherwise
      
      error('### Model must be either from the ''matrix'' or the ''ssm'' class. Please check the inputs.')
  end
  
end

%--------------------------------------------------------------------------
%      Reorganize the model. Used to create lighter versions of 
%      the models to be used in the main loop. 
%--------------------------------------------------------------------------
function modelout = preprocessModel(model, freqs, mdlFreqDependent, ...
                                    inNames, outNames)

  modelout = copy(model,1);

  switch class(model)
    case 'matrix'
      for i = 1:numel(modelout.objs)
        if (mdlFreqDependent)
          % set Xvals
          modelout.objs(i).setXvals(freqs);
          % set alias
          modelout.objs(i).assignalias(modelout.objs(i),plist('xvals',freqs));
        else
          modelout.objs(i).setXvals(1);
        end
      end
    case 'ssm'
      modelout.clearNumParams;
      spl = plist('set', 'for bode', ...
      'outputs', outNames, ...
      'inputs', inNames);
      % first optimise our model for the case in hand
      modelout.reorganize(spl);
      % make it lighter
      modelout.optimiseForFitting();
  end
  
end

%--------------------------------------------------------------------------
%      Metropolis algorithm
%--------------------------------------------------------------------------
function [xo x0 loglk1 loglk2 rejected] = metropolis(k,betta,xn,xo,loglk1,loglk2,numpars)

  x0 = xo(k,1:numpars(k));

  logalpha = betta*(loglk2 - loglk1);

  if logalpha < 0
    xo(k,1:numpars(k)) = xn;
    loglk1 = loglk2;
    rejected = false;
  elseif rand(1) > (1 - exp(-logalpha))
    xo(k,1:numpars(k)) = xn;
    loglk1 = loglk2;
    rejected = false;
  else
    rejected = true;
    loglk2 = loglk1;
  end

end

%--------------------------------------------------------------------------
%      Propose a new point in the parameter space function
%--------------------------------------------------------------------------
function [xn hjump]= propose(xo,cov,search,Tc,jumps,hjump,nacc)

  if search
    
    if nacc <= Tc(1)
      if(mod(nacc,10) == 0 && mod(nacc,25) ~= 0 && mod(nacc,100) ~= 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(2)^2*cov;
      elseif(mod(nacc,20) == 0 && mod(nacc,100) ~= 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(3)^2*cov;
      elseif(mod(nacc,50) == 0 && hjump  ~= 1)
        hjump = 1;
        modcov = jumps(4)^2*cov;
      else
        hjump = 0;
        modcov = jumps(1)^2*cov;
      end
    else
      modcov = 2*cov;
    end
    
    xn = utils.math.drawSample(xo,modcov);
    
  else
    
    xn = utils.math.drawSample(xo,cov);
    
  end

end

%--------------------------------------------------------------------------
%      Compute heat factor
%--------------------------------------------------------------------------
function betta = computeBetta(nacc,Tc,xi)

  if ~isempty(Tc)
    if nacc <= Tc(1)  
      betta = 1/2 * 10^(-xi*(1-Tc(1)/Tc(2)));
    elseif Tc(1) < nacc  && nacc <= Tc(2)
      betta = 1/2 * 10^(-xi*(1-nacc/Tc(2)));
    else
      betta = 1/2;
    end
  end
  
end

%--------------------------------------------------------------------------
%      List all parameters in a cell array 
%--------------------------------------------------------------------------
function [allparams maxnumpars numpars allnumparams] = listparams(params)

  nummodels = numel(params);

  % Get biggest # of parameters & # of params for each model
  numpars    = zeros(1,nummodels);
  
  for k = 1:nummodels; numpars(k) = numel(params{k}); end
  
  maxnumpars = max(numpars);

  allparams = params{1};
  
  nn = numpars(1);
  
  for kk = 2:nummodels
    for jj = 1:numpars(kk)  
      if ~strcmp(allparams,params{kk}{jj})
        allparams{nn} = params{kk}{jj};
        nn = nn + 1; 
      end
    end                              
  end
  
  allnumparams = 1;

end

%--------------------------------------------------------------------------
%      Update parameters function (dimension matching)
%--------------------------------------------------------------------------
function xn = updateparams(param,numpars,xo,k,kn)

    % Dimension difference of models
    dimdif         = abs(size(param{kn},2) - size(param{k},2));
    
    % Mark the different parameters
    difparams      = setxor(param{kn},param{k});
    
    % Total number of different parameters
    totalnumdifpar = numel(difparams);
    kk = 0;
    
    % Case: dimension difference equals the # of different parameters
    % and dim(model(k')) > dim(model(k))
    if (dimdif == totalnumdifpar && size(param{kn},2) > size(param{k},2))
        
       xn = zeros(size(xo(kn,1:numpars(kn))));
       for ii = 1:min(numel(difparams)) 
         compvec{ii}      = strcmp(difparams{ii},param{kn});   
         position(ii)     = find(compvec{ii});% mark the positions of the different parameters
         xn(position(ii)) = xo(kn,position(ii)); 
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk     = kk+1;
           xn(jj) = xo(k,kk);
        end
       end
    
    % Case: dimension difference equals the # of different parameters
    % and dim(model(k')) < dim(model(k))   
    elseif (dimdif == totalnumdifpar && size(param{kn},2) < size(param{k},2))
        
       xn = zeros(size(xo(kn,1:numpars(kn))));
       for ii = 1:min(numel(difparams)) 
         compvec{ii}  = strcmp(difparams{ii},param{k});   
         position(ii) = find(compvec{ii});                
       end     
       for jj = 1:size(param{k},2)
         if (jj ~= position)
           kk     = kk+1;
           xn(kk) = xo(k,jj);
         end
       end
    
    % Case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) > dim(model(k))
    elseif (dimdif < totalnumdifpar && size(param{kn},2) > size(param{k},2))
        
       xn = zeros(size(xo(kn,1:numpars(kn))));
       for ii = 1:min(numel(difparams)) 
         compvec{ii} = strcmp(difparams{ii},param{kn}); 
           if any(compvec{ii})
             position(ii) = find(compvec{ii});                
             xn(position(ii)) = xo(kn,position(ii));
           end
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk     = kk+1;
           xn(jj) = xo(k,kk);
        end
       end
    
    % Case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) < dim(model(k))   
    elseif (dimdif < totalnumdifpar && size(param{kn},2) < size(param{k},2))
        
       xn = zeros(size(xo(kn,1:numpars(kn))));
       for ii = 1:numel(param{kn}) 
         compvec{ii} = strcmp(param{kn}{ii},param{k});
         if any(compvec{ii})
           position(ii) = find(compvec{ii});                
           %xn(position(ii)) = xo{k}(position(ii)); 
         else
           kk = kk+1;
           compvec{ii}       = strcmp(param{kn}{ii},param{kn});
           position2(kk)     = find(compvec{ii});
           xn(position2(kk)) = xo(kn,position2(kk));  
           position(ii) = 0;
         end
       end
       kk = 0;
       for jj = 1:numel(param{kn})
        if (position(jj) ~= 0)
           xn(jj) = xo(k,position(jj));
        end
       end   
       
    % Case: dimension difference is smaller than the # of different parameters
    % and dim(model(k')) = dim(model(k))   
    elseif (dimdif < totalnumdifpar && size(param{kn},2) == size(param{k},2))
        
       xn = zeros(size(xo(kn,1:numpars(kn))));
       for ii = 1:min(size(difparams,2)) 
         compvec{ii} = strcmp(difparams{ii},param{kn}); 
           if any(compvec{ii})
           position(ii)     = find(compvec{ii});                
           xn(position(ii)) = xo(kn,position(ii));
           else 
           position = 0;  
           end
       end     
       for jj = 1:size(param{kn},2)
        if (jj ~= position)
           kk     = kk+1;
           xn(jj) = xo(k,kk);
        end
       end
     
    % Case: new model proposed is the same as the previous one (k' == k).
    % That means we perform again the metropolis algorithm.
    elseif (totalnumdifpar == 0 && size(param{kn},2) == size(param{k},2))
       
       xn = xo(k,1:numpars(k));
        
    end
    
end

%--------------------------------------------------------------------------
%      Compute proposal density
%--------------------------------------------------------------------------
function logq = logprpsl(X,mean,cov)

logq = log(mvnpdf(X,mean,cov));

if (logq == -Inf || logq == Inf) 
  logq = 0; 
end

end

%--------------------------------------------------------------------------
%      Logpriors
%--------------------------------------------------------------------------
function logp = logpriors(r,lp)

  logpr = zeros(1,numel(r(1,:)));

  for ii = 1:numel(r(1,:))
    if lp(ii)
      logpr(ii) = log(1 ./ (exp(r(2,ii)) - exp(r(1,ii))));
    else
      logpr(ii) = log(1 ./ (r(2,ii) - r(1,ii)));
    end
  end
  
  logp = sum(logpr);
  
end

%--------------------------------------------------------------------------
%      Get Info Object
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
%      Get Default Plist
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

  % Method FREQUENCIES VECTOR SCALE MATRIX INMODEL MODEL LOG-LIKELIHOOD
  p = param({'method',['Method to use to compare two (or more) models. The choises available are; RJMCMC, ',...
                       'Laplace-Metropolis (LM), Laplace-Fisher (LF) and Schwarz-Bayes Information Criterion ',...
                       '(SBIC). Default is RJMCMC. Each method needs some ',...
                       'compulsory fields to be filled in the plist.']},   {1, {'RJMCMC' 'LF' 'LM' 'SBIC'}, paramValue.OPTIONAL});
  pl.append(p);

  % inNames
  p = param({'inNames','Input names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % outNames
  p = param({'outNames','Output names. Used for ssm models'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % Model
  p = param({'models','A cell array input of models.'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % Param
  p = param({'FitParams','A cell array of evaluated parameters for each model.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % Input
  p = param({'input','A matrix array of input signals.'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % N
  p = param({'N','number of samples of the chain.'}, paramValue.DOUBLE_VALUE(1000));
  pl.append(p);

  % Neff
  p = param({'Neff',['Number of effective samples to be used for the estimation of the SBIC. If left empty, then'...
                     ' Neff = number of samples of the data.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % Sigma
  p = param({'cov','Cell array containing the covariances of the gaussian jumping distribution for each model.'}, paramValue.DOUBLE_VALUE(1e-4));
  pl.append(p);

  % Noise
  p = param({'noise','A matrix array of noise spectrum (PSD) used to compute the likelihood.'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % Search
  p = param({'modelFreqDependent','Set to true to use frequency dependent s models, set to false when using constant models'}, paramValue.TRUE_FALSE);
  pl.append(p);

  % Search
  p = param({'search','Set to true to use bigger jumps in parameter space during annealing and cool down.'}, paramValue.TRUE_FALSE);
  pl.append(p);

  % Frequencies
  p = param({'frequencies','Range of frequencies where the analysis is performed. If an array, only first and last are used'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % Resample
  p = param({'fsout','Desired sampling frequency to resample the input time series'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % heat
  p = param({'heat','The heat index flattening likelihood surface during annealing.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);

  % Tc
  p = param({'Tc','An array of two values setting the initial and final value for the cooling down.'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % initial values
  p = param({'x0','The proposed initial values (cell array again).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % ranges
  p = param({'range','Ranges'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % BurnIn
  p = param({'BurnIn','If method is RJMCMC, choose number of samples to be discarded to compute B.'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);

  % jumps
  p = param({'jumps',['An array of four numbers setting the rescaling of the covariance matrix during the search phase.',...
                      'The first value is the one applied by default, the following thhree apply just when the chain sample is',...
                      'mod(10), mod(25) and mod(100) respectively.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % plot BF
  p = param({'plot BF',['Case: RJMCMC: If set equal to true, the evolution of the Bayes factor and the Loglikelihoods'...
                        'are plotted every 500 steps. Case: LM: vector for plotting the chains during the mcmc runs.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % plot parameters
  p = param({'plot parameters','A cell array that includes the parameters names desired to create the trace plots.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % debug
  p = param({'debug','Set to true to get debug information of the MCMC process.'}, paramValue.FALSE_TRUE);
  pl.append(p);

  % outModel
  p = param({'outModel','Output model. Still under test'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % Noise
  p = param({'Scale matrix',['A matrix array of noise spectrum (PSD) used to compute the likelihood. ' ...
                             'It is possible to input just a scale matrix, containing the desirable weights.']}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % log-parameters
  p = param({'log parameters','Select the parameters to be treated in log scale.'}, paramValue.EMPTY_STRING);
  pl.append(p);

  % loglikelihood
  p = param({'log-likelihood',['The log-likelihood to sample with the MH algorithm. If left empty, ' ...
                               'then the standard Gaussian approximation will be employed.']},  paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'frequencies vector',['A vector of frequencies. Used for the update of the ' ...
                                   'Fisher Matrix during the MH sampling.']},   {1, {200}, paramValue.EMPTY_DOUBLE});
  pl.append(p);
  
  % inModel
  p = param({'inModel','Input model. Still under test'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Print Freq
  p = param({'Fprint',['Print progress on screen every ' ...
                      'specified numeber of samples.']}, paramValue.DOUBLE_VALUE(100));
  pl.append(p);

end

