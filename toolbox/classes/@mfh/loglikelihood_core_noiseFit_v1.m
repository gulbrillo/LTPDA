% loglikelihood_core_noiseFit_v1: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects with a cross-spectrum matrix that
% depends on parameter values.
%
% [loglik snr] = loglikelihood_core_noiseFit_v1(h,xn,data,etas, np);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h    - The MFH template.
%           S    - The Noise model (cross-spectrum matrix).
%           xn   - The parameter values (vector).
%           data - A structure array containing the data. For more 
%                  information please check MCMC.ao2strucArrays 
%           etas - The eta amplitudes of the PSD of the noise.   
%           np   - The index of the noie parameters.
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core_noiseFit_v1(varargin)
  
  h    = varargin{1};
  xn   = varargin{2};
  data = varargin{3};
  etas = varargin{4};
  np   = varargin{5};
  k0   = varargin{6};
  L    = 0;
  snr  = 0;
  Nexp = size(h,2);
  Lf   = cell(1,Nexp);
  
  logLexp    = zeros(1,Nexp);
  snrexp     = zeros(1,Nexp);
  vec_norm   = [];
  SegSamples = zeros(1, numel(np));
  
  % Get the double out of the pest (if applicable)
  double_xn = double(xn);
  double_xn = double_xn(:).';
  
  % loop over experiments
  for kk = 1:Nexp

    % calculate (s-d)
    hmat(kk).hs = h(kk).eval(xn);
    
    % get noise 
    for jj = 1:numel(np)
      vec_norm       = [vec_norm ; double_xn(np(jj)).*etas{kk}{jj}];
      SegSamples(jj) = numel(etas{kk}{jj});
    end      
    
    % inverse
    n = data(kk).noise./(vec_norm);
    
    % Get logL(f) / chi^2
    Lf{kk} = real(utils.math.ctmult(hmat(kk).hs, utils.math.mult(n, hmat(kk).hs)));

    % L: Sum over frequencies
    logLexp(kk) = -0.5.*(sum(Lf{kk}(k0:end)) + 2*sum(SegSamples.*log(double_xn(np))));
    
    snrexp(kk)  = logLexp(kk);

    % SNR calculation (not applicable for MFH)
    % Get h^2
    % hh = utils.math.ctmult(hmat(kk).hs,utils.math.mult(data(kk).noise, hmat(kk).hs));
    % snrexp(kk) = sqrt(2)*real(sum(hh).^2/sum(hh));
    
    L = L + logLexp(kk);
    
    snr  = snr + snrexp(kk);
    
    % Empty array
    vec_norm = [];
    
  end
  
  % Set output
  varargout{1} = L;
  varargout{2} = snr;
  varargout{3} = Lf;
  varargout{3} = logLexp;
  varargout{4} = snrexp;
  
end

% END