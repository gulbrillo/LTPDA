% MAIN.M
%
% The main MCMC algorithm function. It defines the protocol of the
% algorithm wich consists of checking the inputs, build a likelihood
% function, calculate the covariance, and finally sample the parameter
% space with the Metropolis-Hastings algorithm.
%
% Protocol:
%
%    - performDataChecks()
%    - buildLogLikelihood()
%    - calculateCovariance()
%    - simplex()
%    - mhsample()
%
% NK 2015
%
function varargout = main(varargin)
  
  % Gather inputs
  if nargin==1
    algo = varargin{1};
  else
    algo    = varargin{1};
    objects = varargin{2};
  end
  
  import utils.const.*
  
  % Get the algorithm history
  algoHist = algo.hist;
  
  % Collect system output data
  objHists = algo.collectOutputAOs(objects);
  
  % perform checks on data
  algo.performDataChecks();
  
  % Build the log-likelihood function
  algo.buildLogLikelihood();
  
  % Calculate covariance
  algo.calculateCovariance();
  
  % Define a data plist for convenience
  data_pl = plist('INNAMES', algo.params.find('inNames'),'OUTNAMES', algo.params.find('outNames'), 'MODEL', algo.processedModel);
  
  % Start building the mhsample input plist.
  mhsample_pl = algo.params.subset(getKeys(MCMC.getInfo('MCMC.mhsample').plists));
  mhsample_pl.pset(data_pl.params, 'DIFF MODEL', algo.model, 'LOGLIKELIHOOD', algo.loglikelihood);
  
  % Do a simplex search first?
  if algo.params.find('SIMPLEX')
    
    utils.helper.msg(msg.IMPORTANT, 'Preparing for a simplex search ...', mfilename('class'), mfilename);
    
    smplx_plist = algo.params.subset(getKeys(MCMC.getInfo('MCMC.simplex').plists));
    
    smplx_plist.pset('FITPARAMS',      algo.getParamNames(),...
                     'LOG PARAMETERS', algo.logParams(),...
                     'FREQS',          algo.freqs,...
                     'FUNC',           algo.loglikelihood, data_pl.params);
    
    smplx_estimates = algo.simplex(algo.outputs, smplx_plist);
    
    % Set x0 for MH search if simplex search was performed.
    mhsample_pl.pset('X0', smplx_estimates);
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%  Perform MH Sampling  %%%%%%%%%%%%%%%%%%%%%%%
  
  if algo.params.find('MHSAMPLE')
    
    % Check the likelihood version and add the prior ...
    if strcmpi(algo.params.find('LLH VER'), 'NOISE FIT V1') && isempty(algo.params.find('PRIOR'))
      mhsample_pl.pset('PRIOR', algo.loglikelihood.procinfo.find('prior'));
    end
    
    % Fill the mhsample plist
    mhsample_pl.pset(...
                    'FREQUENCIES VECTOR', algo.freqs, ...
                    'COV',                algo.covariance,...
                    'FITPARAMS',          algo.getParamNames());
    
    % check if x0 is not provided. If not, pick a random point
    % between the ranges specified.
    algo.checkXo();
    
    estimates = algo.mhsample(combine(data_pl, mhsample_pl));   
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%  Set output  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  % Arrange output objects depending on the choices of likelihood
  % minimization methods.
  if algo.params.find('MHSAMPLE') && algo.params.find('SIMPLEX')
    
    estimates.procinfo.append('Simplex estimates', smplx_estimates)
    
  elseif algo.params.find('SIMPLEX') && ~algo.params.find('MHSAMPLE')
    
    estimates = copy(smplx_estimates, 1);
    
  end
  
  % Set the pest object
  algo.pest = estimates;
  
  % Add history
  algo.addHistory(processInfo(algo), [], {}, [algoHist objHists]);
    
  % Set output
  varargout{1} = algo;
  
end % END of main function