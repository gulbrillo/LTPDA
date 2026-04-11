% loglikelihood_core_student: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects with a cross-spectrum matrix that
% depends on parameter values, as described in PRD 84, 122004 (2011).
%
% [loglik snr] = loglikelihood_core_student(h,xn,data,nu,np);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h    - The MFH template.
%           S    - The Noise model (cross-spectrum matrix).
%           xn   - The parameter values (vector).
%           data - A structure array containing the data. For more 
%                  information please check MCMC.ao2strucArrays 
%           nu   - The nu coefficients for the PSD of the noise.   
%           np   - The index of the noie parameters.
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core_student(varargin)
  
  h    = varargin{1};
  xn   = varargin{2};
  data = varargin{3};
  NU   = varargin{4};
  np   = varargin{5};
  k0   = varargin{6};
  L    = 0;
  snr  = 0;
  Nexp = size(h,2);
  Lf   = cell(1,Nexp);
  
  logLexp = zeros(1,Nexp);
  snrexp  = zeros(1,Nexp);
  nu_vec  = [];
  
  % loop over experiments
  for kk = 1:Nexp

    % calculate (s-d)
    hmat(kk).hs = h(kk).eval(xn);
    
    % get nu vector to multiply the noise 
    if ~isempty(np)
      for jj = 1:numel(np)
        nu_vec = [nu_vec ; xn(np(jj)).*NU{kk}{jj}];
      end      
    else
      nu_vec = NU{kk}{1};      
    end
    
    % inverse
    n = data(kk).noise./nu_vec;
      
    % Get logL(f) / chi^2
    Lf{kk} = real(utils.math.ctmult(hmat(kk).hs, utils.math.mult(n, hmat(kk).hs)));

    % L: Sum over frequencies
    logLexp(kk) = -sum( ((nu_vec + 2)./2) .* log(1 + Lf{kk}(k0:end)));
    
    snrexp(kk)  = logLexp(kk);

    % SNR calculation (not applicable for MFH)
    % Get h^2
    % hh = utils.math.ctmult(hmat(kk).hs,utils.math.mult(data(kk).noise, hmat(kk).hs));
    % snrexp(kk) = sqrt(2)*real(sum(hh).^2/sum(hh));
    
    L = L + logLexp(kk);
    
    snr  = snr + snrexp(kk);
    
  end
  
  % Set output
  varargout{1} = L;
  varargout{2} = snr;
  varargout{3} = Lf;
  varargout{3} = logLexp;
  varargout{4} = snrexp;
  
end

% END