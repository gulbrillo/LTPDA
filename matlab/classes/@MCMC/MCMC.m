% MCMC - Markov Chain Monte Carlo algorithm
%
%        MCMC sampling with the Metropolis-Hastings algorithm. This
%        method has the capability to automativally pre-process the 
%        time-series data to analyse (FFT of signals, PSD of the noise).
%        The covariance matrix to be used for the proposal distribution
%        is computed as the inverse of the Fisher Information Matrix.
%
%        This algorithm is designed to perform as pipeline analysis
%        for LPF time series data analysis. For arbitrary statistical 
%        analysis, it is recommended to use the MCMC.mhsample function
%        with a user defined log-likelihood to sample.
%
%    CALL:
%             m = MCMC(pl)
%             p = m.process(data)
%
%  INPUTS:
%          data - an array of matrix or ao objects
%
% OUTPUTS:
%
%             p - pest object containing the sampling results of the
%                 posterior distribution. The diagnostics of the chains
%                 is stored in the procinfo property of the pest object.
%
% NOTE:
%
% In the input data is an array of matrix objects, then each matrix object
% should represent a single experiment, with a single column, and one row
% per system output. If the input data is an array of AOs, then each column
% should represent one experiment, and each row represents an output of the
% system.
%
% The same applies when the model is a MFH object. In principle, the 
% field 'input' should be left empty. The number of channels is taken
% from the size of the MFH object: 
%
% Nchannels    = size(mfh_model,1);
% Nexperiments = size(mfh_model,2);
%
% For this case, the 'noise' can be either a MATRIX, an AO, or a MFH object.
%
% <a href="matlab:web(['text://' MCMC.getInfo.tohtml])">Parameters Description</a>
%
% 2014
% 
classdef MCMC < ltpda_algorithm
  
  properties (Access=public)
    model         = [];
    inputs        = [];
    noise         = [];
    covariance    = [];
    diffStep      = [];
  end
  
  properties (Access=protected)
    logParams      = []; % True/false vector indicating params sampled in log
    processedModel = []; % Processed model for fast computations
    freqs          = []; % The frequencies of the analysis 
    outputs        = []; % The collected AO objects 
    pest           = [];
    loglikelihood  = [];
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = MCMC(varargin)
      
      % set details
      name        = mfilename;
      package     = 'ltpda';
      category    = utils.const.categories.sigproc;
      description = ['The Markov Chain Monte Carlo method performs parameter '...
                     'estimation by sampling the parameter space with the '...
                     'Metropolis-Hastings algorithm.'];
      
      % call superclass
      obj = obj@ltpda_algorithm(name, package, category, description, varargin{:});
      
    end
    
  end
  
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%                             Methods (public)                              %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	methods (Access = public)
	
	  varargout = buildLogLikelihood(varargin)
	  varargout = calculateCovariance(varargin)
    varargout = setModel(varargin)
	  varargout = setNoise(varargin)
	  varargout = setInputs(varargin)
    varargout = getPest(varargin)
    varargout = getLikelihood(varargin)
    
  end % End of public methods
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    vararout = performDataChecks(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    varargout = drawSample(varargin)
    varargout = processChain(varargin)
    varargout = ao2strucArrays(varargin)
    varargout = mhsample(varargin)
    varargout = simplex(varargin)
    varargout = initObjectWithSize(n,m)
    varargout = preprocessMFH(varargin)
    varargout = plotLogLikelihood(varargin)
    varargout = computeICSMatrix(varargin)
    varargout = handle_data_for_icsm(varargin)
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function reports = run_tests()
      reports = ltpda_algorithm.run_tests(mfilename('class'));
    end
    
    function tests = test_list(varargin)
      tests = [ltpda_algorithm.list_tests('ltpda_algorithm') ltpda_algorithm.list_tests(mfilename('class'))];
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function plout = getDefaultPlist(set)
      if nargin==0
        set = 'Default';
      end
      persistent pl;
      persistent lastset;
      if exist('pl', 'var') == 0 || isempty(pl) || ~strcmp(lastset, set)
        pl = MCMC.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
  end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (protected)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    
    varargout = preprocess(varargin)
    varargout = collectOutputAOs(varargin)
    varargout = main(varargin)
    varargout = fromStruct(varargin)

  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    varargout = buildplist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (private)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    
    varargout = checkXo(varargin)
    varargout = getParamNames(varargin)
    varargout = preprocessModel(varargin)
    varangout = checkDiffStep(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    
    varargout = defineLogLikelihood(varargin)
    varargout = decision(varargin)
    varargout = logDecision(varargin)
    varargout = jump(varargin)
    varargout = computeBeta(varargin)
    varargout = mhutils(varargin)
    varargout = updateFIM(varargin)
    varargout = drawAdaptiveSample(varargin)
    varargout = checkP0class(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                       Methods (public, static, Hidden)                    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
end

% END