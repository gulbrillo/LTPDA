% loglikelihood_core_log: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects as defined in PRD 90, 042003
%
% loglik = loglikelihood_core_log(h,xn,Navs,olap,freqs,trim,win, k0, k1, fs, dtrnd, segs, t0, toffset);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h       - The MFH template.
%           xn      - The parameter values (vector).
%           Navs    - The number of averages
%           olap    - The level of overlap.   
%           freqs   - The minimum and maximum frequenct of the analysis.
%           trim    - Chopping samples from the time series -> avoid transients
%           win     - The window name
%           k0      - The 1st FFT coefficient
%           k1      - The k1 FFT coefficient 
%           fs      - The sampling frequency
%           dtrnd   - The detrend order of each segment
%           segs    - The custom timespan in case of user-split data 
%           t0      - The t0 of the time-series
%           toffset - The Toffset of the time series.
%
%           *The last three entries are used for the reconstruction of the 
%            time vector used to split the data.
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core_log(varargin)
  
  h       = varargin{1};
  xn      = varargin{2};
  Navs    = varargin{3};
  olap    = varargin{4};
  freqs   = varargin{5};
  trim    = varargin{6};
  win     = varargin{7};
  k0      = varargin{8};
  k1      = varargin{9};
  fs      = varargin{10};
  dtrnd   = varargin{11};
  segs    = varargin{12};
  t0      = varargin{13};
  toffset = varargin{14};
  snr     = 0;
  Nexp    = size(h,2);
  Lf      = cell(1,Nexp);
  L_exp  = zeros(1,Nexp);
  L       = 0;
  
  % loop over experiments
  for kk = 1:Nexp

    % calculate (s-d), the time series
    ts = h(kk).eval(xn);
    
    % do the PSD/FFT
    hs = utils.math.psd(ts, Navs, olap, trim, win, freqs, fs, dtrnd, t0, toffset, segs);
    
    % downsample with respect to k0, k1
    hs = hs(k0:k1:end);
    
    % Get logL(f)
    Lf{kk}    = -real(log(hs)).*Navs;
    
    % Get sum_f [logL(f)]
    L_exp(kk) = sum(Lf{kk});
    
    % Sum experiments
    L = L + L_exp(kk);
    
    snr  = snr + L_exp(kk)./Navs;
    
  end
  
  % Set output
  varargout{1} = L;
  varargout{2} = snr;
  varargout{3} = L_exp;
  %varargout{3} = Navs.*snrexp(kk);
  varargout{4} = Lf;
  
end

% END