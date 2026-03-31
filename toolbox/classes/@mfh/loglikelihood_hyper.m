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

function varargout = loglikelihood_hyper(varargin)
  
  h     = varargin{1};
  xn    = varargin{2};
  data  = varargin{3};
  k0    = varargin{4};
  np    = varargin{7};
  L     = 0;
  snr   = 0;
  Nexp  = size(h,2);
  Nout  = size(h,1);
  Lf    = cell(1,Nexp);
  
  % Get distribution parameters
  double_xn = double(xn);
  if isempty(np)
    a     = varargin{5};
    delta = varargin{6};
    d     = numel(double_xn);
  else
    a     = double_xn(np(1));
    delta = double_xn(np(2));
    d     = numel(double_xn) - 2;
  end
  
  logLexp = zeros(1,Nexp);
  snrexp  = zeros(1,Nexp);
  
  for kk = 1:Nexp

    for ii = 1:Nout
      hmat(kk).hs(:,ii) = h(ii,kk).eval(xn);
    end
    
    % Get logL(f)
    Lf{kk} = real(utils.math.ctmult(hmat(kk).hs, utils.math.mult(data(kk).noise, hmat(kk).hs)));

    % Get the modified Bessel of the third kind
    K = besselk((d+1)/2, abs(a*delta));
    
    % L: Sum over frequencies for the hyperbolic distribution 
    logLexp(kk) = numel(Lf{kk})*(((d+1)/2).*(log(a) - log(delta)) - log(2*a) - log(abs(K + 1e-90)))  - a.*sqrt(delta^2 + sum(Lf{kk}(k0:end)));
    
    snrexp(kk)  = logLexp(kk);
    
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