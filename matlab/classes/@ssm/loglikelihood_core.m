% LOGLIKELIHOOD: Compute log-likelihood for SSM objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for SSM objects.
%
% [LLH SNR LLHexp SNRexp LLH(f)] = loglikelihood(model,xn,in,out,noise,params, lp, spl);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   model     - The symbolic SSM system.
%           data      - The data (in, out, noise) in a structure array.
%           xn        - The parameter values (vector).
%           params    - Cell array with the parameter names.
%           freqs     - The frequencies of the analysis.
%           lp        - A vector of zeros and ones, denoting the position.
%                       of a log-parameter.
%
% OUTPUTS:  LLH - The LLH value for all experiments.
%           SNR - The SNR value for all experiments.
% LLHexp SNRexp - The LLH, SNR values for each experiment.
%        LLH(f) - The LLH as a function of frequency (cell array).
%
% M. Nofrarias, N. Karnesis 2012
%

function varargout = loglikelihood_core(varargin)
  
  persistent processedModel
  persistent sourceModel
  
  system = varargin{1};
  xn     = varargin{2};
  data   = varargin{3};
  params = varargin{4};
  lp     = varargin{5};
  spl    = varargin{6};
  
  % Get # of inputs and outputs
  Nout = numel(data(1).output(1,:));
  Nin  = numel(data(1).input(1,:));
  Nexp = numel(data);
  logL = 0;
  snr  = 0;
  
  % Checking for parameters in log-space
  ind = find(lp == 1);
  xn(ind) = exp(xn(ind));
  logLexp = zeros(1,Nexp);
  snrexp  = zeros(1,Nexp);
  Lf      = cell(1, Nexp);
  
  if isempty(processedModel) || ~strcmp(sourceModel, system.UUID)
    disp('copying system...');
    processedModel = copy(system, 1);
    sourceModel = system.UUID;
  end
  
  for k = 1:Nexp
    
    processedModel.setA(system.amats);
    processedModel.setB(system.bmats);
    processedModel.setC(system.cmats);
    processedModel.setD(system.dmats);
    
    % Set parameter values
    processedModel.doSetParameters(params, xn);
    
    % Make numeric
    processedModel.doSubsParameters(params, true);
    
    % Do bode
    h  = bode(processedModel, spl(k));
    
    % Get numbers
    h  = h.objs.y;
    
    % Re-arrange the transfer functions according to Nin, Nout...
    hmat      = reshape(h,numel(h(:,1)),Nout,Nin);
    
    % Calculate the log-likelihood
    [logLexp(k), snrexp(k), Lf{k}] = utils.math.loglikelihood(data(k).input, data(k).output, data(k).noise, hmat);
    
    logL = logL -0.5.*logLexp(k);
    
    snr  = snr + snrexp(k);
    
  end
  
  % Set output
  varargout{1} = logL;
  varargout{2} = snr;
  varargout{3} = -0.5.*logLexp;
  varargout{4} = snrexp;
  varargout{5} = Lf;
  
end

% END