% modelSelect method to compute the Bayes Factor using RJMCMC, LF, LM, BIC methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     modelSelect - method to compute the Bayes Factor using
%                   RJMCMC, LF, LM, BIC methods
%
%            call - Bxy = modelselect(out,pl)
%
%          inputs - out: matrix objects with measured outputs
%                   pl:  parameter list
%
%         outputs - Bxy:
%                   -RJMCMC:
%                     An array of AOs containing the evolution
%                     of the Bayes factors. (comparing each model 
%                     with each other)
%
%                   -LM, LF, SBIC:
%                     An ao containing the Bayes Factor for the 
%                     comparison of 2 models
%      
% <a href="matlab:utils.helper.displayMethodInfo('ao','modelSelect')">Parameters Description</a>
%
%   N. Karnesis 27/09/2011 
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = modelSelect(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Method can not be used as a modifier
  if nargout == 0
    error('### mcmc cannot be used as a modifier. Please give an output variable.');
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs smodels and plists
  [aos_in, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);

  % copy input aos
  aos = copy(aos_in,1);
  
  % Get parameters
  cvarIn     = find_core(pl, 'cov');
  rnge       = find_core(pl, 'range');
  params     = find_core(pl, 'FitParams');
  method     = find_core(pl, 'method');
  N          = find_core(pl, 'N');
  mdlin      = find_core(pl, 'models');
  thetas     = find_core(pl, 'thetaMAP');
  sample     = find_core(pl, 'sample');
  bi         = find_core(pl, 'BurnIn');
  Neff       = find_core(pl, 'Neff');
  xo         = find_core(pl, 'x0');
  jumps      = find_core(pl, 'jumps');
  param      = find_core(pl, 'FitParams');
  outNames   = find_core(pl, 'outNames');
  inNames    = find_core(pl, 'inNames');
  logparams  = find_core(pl, 'log parameters');
  likelihood = find_core(pl, 'log-loglikelihood');
  mdlFreqDep = find_core(pl, 'modelFreqDependent');
  
  % Get the mve plist
  mve_keys  = getAllKeys(ao.getInfo('mve').plists);
  mve_pl    = pl.subset(mve_keys);
  
  % Get # of models
  nummodels  = numel(mdlin);
  
  % Make them lighter
  models = cell(1,nummodels);
  for k = 1:nummodels
    models{k} = copy(mdlin{k},1);
    models{k}.clearHistory;
    if isa(models{k}, 'ssm')
      models{k}.clearNumParams;
      models{k}.clearAllUnits;
      models{k}.params.simplify;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%  Preprocess the Data  %%%%%%%%%%%%%%%%%%%%%%%%%
  
  data_keys  = getAllKeys(ao.getInfo('preprocessDataForMCMC').plists);
  data_plist = pl.subset(data_keys);
  
  [fin, fout, S, ~, freqs, ~,inModel, outModel] = preprocessDataForMCMC(aos,data_plist);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%  Perform Checks on Inputs  %%%%%%%%%%%%%%%%%%%%
  
  % Get # of experiments
  Nexp = numel(fout(1,:));

  cvar      = cell(1,nummodels);
  
  if ~isempty(cvarIn) && ~strcmp(method,'SBIC')
    for k = 1:nummodels
      % get covariance values
      if isa(cvarIn{k}, 'ao')
        cvar{k} = cvarIn{k}.y;
      elseif isnumeric(cvarIn{k})
        cvar{k} = cvarIn{k};
      else
        error(['### Covariance matrices must be either a pure numerical matrices,'...
               'either AOs in a cell array.']);
      end
    end
  end
  
  pl = pset(pl,'cov',cvar);

  if ~isempty(rnge) && ~iscell(rnge)
    error('### The key ''ranges'' must be a cell array.');
  end

  % Get # of parameters
  Nparams = numel(params);

  if isempty(params)
    error('### Please define the parameters ''params'' to fit.');
  end
  
  % Get biggest # of parameters & # of params for each model
  numpars    = zeros(1,nummodels);
  for k = 1:nummodels; numpars(k) = numel(params{k}); end
  maxnumpars = max(numpars);

  % check for log-parameters
  lp = zeros(maxnumpars,nummodels);
  for k = 1:nummodels
    if ~isempty(logparams)
      for jj = 1:numel(params{k})
        if any(strcmp(params{k}{jj},logparams))
          lp(jj,k) = 1;
        end
      end
    end
  end

  rang = cell(1,nummodels);
  if ~isempty(rnge)
    % Get range for parameters
    for jj = 1:nummodels
      for i = 1:numel(params{1,jj})   
        rang{1,jj}(:,i) = rnge{1,jj}{i}';
      end
    end
  end
  
  if isempty(jumps)
    warning('LTPDA:mcmc', ['### The ''jumps'' field of the plist is empty. The rescaling of the',...
                           ' covariance matrix during heating will be deactivated.'])
    jumps = ones(1,Nparams);
    pl    = pset(pl,'jumps',jumps);

  end
  
  %%%%%%%%%%%%%%%%%%%  Define log-likelihood  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if isempty(likelihood)
    
    utils.helper.msg(msg.IMPORTANT, 'Defining default log-likelihood function ...', mfilename('class'), mfilename);
      
    % Get the numerical matrices
    mats = ao2numMatrices(fout,plist('in',fin,'S',S,'Nexp',Nexp));

    fin     = mats{1};
    nfout   = mats{2};
    S       = mats{3};
    
    pmodels(1:nummodels) = ssm();
    
    for k = 1:nummodels
      utils.helper.msg(msg.IMPORTANT,sprintf('Pre-processing model # %d...',k), mfilename('class'), mfilename);
    
      pmodels(1,k) = preprocessModel(models{k}, freqs, mdlFreqDep, inNames{k}, outNames{k});
    
      likelihood{k} = getLoglikelihood(fin,nfout,S,pmodels(1,k),param{k},freqs,lp(:,k)',inModel,outModel,inNames{k},outNames{k});
    end
    
  elseif ~isa(likelihood, 'function_handle')
    
    error(['### The function to sample with the MH must be a MATLAB function ' ...
           'handle object. Please check again.'])
         
  end

  chains = {[] []};
  
  % choose method to use to compute the Bayes Factor.
  switch method

    % LM, LF, BIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case {'LF','LM','SBIC'}

      % Perform some sanity checks
      if (numel(models) ~= 2)
          error('Check number of models. LF, LM and BIC methods are implemented to compare only 2 models.')
      end

      if ~sample && (isempty(thetas) || isempty(cvar))
          error('The fields ''thetaMAP'' and ''cov'' must be provided to use the LF and LM methods.')
      end
      
      if sample && (strcmp(method,'LM') || strcmp(method,'SBIC'))     
        if (isempty(xo))
          error('The field ''x0'' must be provided to use the LM and BIC method if ''sample'' is set to true.')
        end

        if (isempty(rnge))
          error('The field ''range'' must be provided to use the LM and BIC method if ''sample'' is set to true.')
        end
        
        mhsample_pl(1:2) = plist(); 
        p(1:2)           = pest();
        
        for k = 1:2
          % Start building the mhsample input plist.
          mhsample_pl(k) =  plist(...
                                 'Fitparams',         params{k},...
                                 'log parameters',    logparams,...
                                 'frequencies vector',freqs, ...
                                 'Scale matrix',      S, ...
                                 'input',             fin, ...
                                 'outmodel',          outModel,...
                                 'inmodel',           inModel,...
                                 'model',             pmodels(1,k),...
                                 'range',             rnge,...
                                 'log-likelihood',    likelihood{k},...
                                 'x0',                xo{k},...
                                 'cov',               cvar{k},...
                                 'range',             rang{k}...
                                 );
                               
          p(k) = mhsample(fout, mhsample_pl(k));
          
          % Theta_MAP & cov
          thetas{k} = p(k).y';
          cvar{k}   = p(k).cov;
          chains{k} = p(k).chain;
          
          if strcmp(method,'LM')
            
            cvar{k} = mve(ao(chains{k}), mve_pl);
            cvar{k} = cvar{k}.y;
            
          end
        end
      end

      logL  = [0 0];

      % Compute log-likelihood for both models in "theta"
      for k = 1:2
        [logL(k) ~] = likelihood{k}(thetas{k});
      end

      logBF = criterion(method,param,cvar,logL,Neff);

      % compute Bayes Factor
      BayesFactor = ao(exp(logBF));

      % Set output
      BayesFactor.setName(sprintf('B%d%d %s',1,2,method)); 
      BayesFactor.addHistory(getInfo('None'), pl, ao_invars(:), [aos_in(:).hist]);
      BayesFactor.procinfo = plist(...
                                   'Likelihoods',logL,...
                                   'thetas',thetas,...
                                   'cov',cvar,...
                                   'chains',chains);
      
      output    = {BayesFactor};
      varargout = output(1:nargout);  

    % RJMCMC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'RJMCMC'

      % Check input parameters
      if isempty(rnge)
        error('### Please define a search range ''range''');
      end
      if isempty(param)
        error('### Please define the parameters ''param''');
      end
      if (bi >= N)
        error('### BurnIn must not be greater or equal than the total number of samples');
      end
      
      % Start building the mhsample input plist.
      rjsample_keys  =  getAllKeys(ao.getInfo('rjsample').plists);
      rjsample_pl    =  pl.subset(rjsample_keys);

      rjsample_pl    =  pset(rjsample_pl,'frequencies vector',freqs, ...
                                         'Scale matrix',      S, ...
                                         'input',             fin, ...
                                         'outmodel',          outModel,...
                                         'inmodel',           inModel,...
                                         'models',            pmodels,...
                                         'range',             rang,...
                                         'log-likelihood',    likelihood...
                                         );

      Bxy = rjsample(ao(fout), rjsample_pl);
      
      Bxy.addHistory(getInfo('None'), pl, ao_invars(:), [fout(:).hist]);
      output = {Bxy};
      varargout = output(1:nargout);

  end
  
end

%--------------------------------------------------------------------------
% Get Default log-likelihood function given the model format
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
% Get the math formula depending on the method
%--------------------------------------------------------------------------
function logBF = criterion(method,params,cvar,logL,Neff)

  switch method
    
    case 'LF'
      
      logBF = 0.5*(numel(params{1})-numel(params{2}))*log(2*pi) + 0.5*log(det(cvar{1})/det(cvar{2})) -0.5*logL(1) - ( - 0.5*logL(2));
      
    case {'LM', 'SBIC'}
      switch method
        case 'LM'
          
          logBF = 0.5*(numel(params{1})-numel(params{2}))*log(2*pi) - 0.5*log(abs(det(pinv(cvar{1})))/abs(det(pinv(cvar{2})))) -0.5*logL(1) + 0.5*logL(2);
        
        case 'SBIC'
          
          logBF = -0.5*(numel(params{1})-numel(params{2}))*log(Neff) + logL(1) - logL(2);
      
      end
    otherwise
      error('### Sorry, the methods implemented are the LM, LF, BIC and RJMCMC...')
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
if exist('pl', 'var')==0 || isempty(pl)
  pl = buildplist();
end
plout = pl;
end

function pl = buildplist()
  
  pl = plist();

  % Method
  p = param({'method',['Method to use to compare two (or more) models. The choises available are; RJMCMC, ',...
                       'Laplace-Metropolis (LM), Laplace-Fisher (LF) and Schwarz-Bayes Information Criterion ',...
                       '(SBIC). Default is RJMCMC.',...
                       'Each method needs some compulsory fields to be filled in the plist.']},   {1, {'RJMCMC' 'LF' 'LM' 'SBIC'}, paramValue.OPTIONAL});
  pl.append(p);

  % Neff
  p = param({'Neff',['Number of effective samples to be used for the estimation of the SBIC. If left empty, then'...
                     ' Neff = number of samples of the data.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % theta_MAP
  p = param({'thetaMAP',['Cell array containing the parameter vectors that maximize the likelihoods for',...
                         ' two models. Used for LF, LM, SBIC methods.']},   paramValue.EMPTY_DOUBLE);
  pl.append(p);

  % sample
  p = param({'sample',['Used in the case of ''LM'' method to extract covariance matrices. If true, MCMC parameter estimation',...
                       'is applied for both models. If false, the covariance matrices and parameter values in the ''cov'' '...
                       'and ''thetaMAP'' fields are used to calculate the evidence.']},   paramValue.TRUE_FALSE);
  pl.append(p);
  
  % log-parameters
  p = param({'log parameters','Select the parameters to be treated in log scale.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Get keys for mve function
  mve_pl = ao.getInfo('mve').plists;
  
  pl = combine(pl, mve_pl);

  % Get keys for mhsample function
  rjsample_pl = ao.getInfo('rjsample').plists;
  
  pl = combine(pl, rjsample_pl);
  
  % Get keys for preprocess data function
  preprocessDataForMCMC_dpl = ao.getInfo('preprocessDataForMCMC').plists;
  
  pl = combine(pl, preprocessDataForMCMC_dpl);

end


