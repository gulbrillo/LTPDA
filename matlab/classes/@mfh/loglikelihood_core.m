% loglikelihood_core: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects.
%
% [loglik snr] = loglikelihood(model,xn,in,out,noise,params, lp, outModel);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h    - The MFH template.
%           S    - The Noise model (cross-spectrum matrix).
%           xn   - The parameter values (vector).
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core(varargin)
  
  h    = varargin{1};
  xn   = varargin{2};
  data = varargin{3};
  k0   = varargin{4};
  L    = 0;
  snr  = 0;
  Nexp = size(h,2);
  Nout = size(h,1);
  Lf   = cell(1,Nexp);
  
  logLexp = zeros(1,Nexp);
  snrexp  = zeros(1,Nexp);
  
  for kk = 1:Nexp

    for ii = 1:Nout
      hmat(kk).hs(:,ii) = h(ii,kk).eval(xn);
    end
    
    % Get logL(f)
    Lf{kk} = real(utils.math.ctmult(hmat(kk).hs, utils.math.mult(data(kk).noise, hmat(kk).hs)));

    % L: Sum over frequencies
    logLexp(kk) = -(0.5).*sum(Lf{kk}(k0:end));
    
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