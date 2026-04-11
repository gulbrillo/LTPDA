% loglikelihood_core_td: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects in time domain.
%
% [loglik snr] = loglikelihood_core_td(h,data,xn,dy);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h    - The MFH model.
%           dy   - The possible errors on the measirement.
%           xn   - The parameter values (vector).
%           data - The measurement.
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core_td(varargin)
  
  h    = varargin{1};
  data = varargin{2};
  xn   = varargin{3};
  dy   = varargin{4};
  L    = 0;
  snr  = 0;
  Nexp = size(h,2);
  Nout = size(h,1);
  Ls   = cell(1,Nexp);
  
  logLexp = zeros(1,Nexp);
  snrexp  = zeros(1,Nexp);
  
  for kk = 1:Nexp

    for ii = 1:Nout
      hmat(kk).hs(:,ii) = h(ii,kk).eval(xn);
    end
    
    if isempty(dy)
      Ls{kk} = (data - hmat(kk).hs).^2;
    else
      Ls{kk} = ((data - hmat(kk).hs)./dy).^2;
    end

    % L: Sum over data points 
    logLexp(kk) = -(0.5).*sum(Ls{kk});
    
    snrexp(kk)  = logLexp(kk);

    % SNR calculation 
    if ~isempty(dy)
      hh         = (hmat(kk).hs./dy).^2;
      snrexp(kk) = sqrt(2)*real(sum(hh).^2/sum(hh));
    else
      snrexp(kk) = logLexp(kk);
    end
    
    L = L + logLexp(kk);
    
    snr  = snr + snrexp(kk);
    
  end
  
  % Set output
  varargout{1} = L;
  varargout{2} = snr;
  varargout{3} = Ls;
  varargout{3} = logLexp;
  varargout{4} = snrexp;
  
end

% END