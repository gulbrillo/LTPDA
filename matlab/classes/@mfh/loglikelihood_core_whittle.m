% loglikelihood_core_whittle: Compute log-likelihood for MFH objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute log-likelihood for MFH objects as defined in ...
%
% loglik = loglikelihood_core_whittle(h, noise_model, xn, Ns, olap, freqs, trim, win, k0, fs, dtrnd, fsigs);
%
% It is implemented this way to achieve maximum in-loop speed of
% the Metropolis algorithm.
%
% INPUTS:   h       - The MFH template (in frequency domain).
%           noise   - The MFH noise model.
%           xn      - The parameter values (vector).
%           Navs    - The number of averages
%           olap    - The level of overlap.   
%           freqs   - The minimum and maximum frequenct of the analysis.
%           trim    - Chopping samples from the time series -> avoid transients
%           win     - The window name
%           k0      - The 1st FFT coefficient
%           fs      - The sampling frequency
%           dtrnd   - The detrend order of each segment
%           fsigs   - The frequencies of the experiment
%
% OUTPUTS:  logL - The log-likelihood value
%

function varargout = loglikelihood_core_whittle(varargin)
  
  h       = varargin{1};
  noise   = varargin{2};
  xn      = varargin{3};
  Navs    = varargin{4};
  olap    = varargin{5};
  freqs   = varargin{6};
  trim    = varargin{7};
  win     = varargin{8};
  k0      = varargin{9};
  fs      = varargin{10};
  dtrnd   = varargin{11};
  f       = varargin{12};
  snr     = 0;
  Nexp    = size(h,2);
  Lf      = cell(1,Nexp);
  logLexp = zeros(1,Nexp);
  L       = 0;
  Nout    = size(h,1);

  % loop over experiments
  for kk = 1:Nexp

    % calculate (s-d), in frequency domain
     for ii = 1:Nout
      hmat(kk).hs(:,ii) = h(ii,kk).eval(xn)./2;
    end
    
    % evaluate the noise model time series
    for ii = 1:Nout
      noise_ts(kk).hs(:,ii) = noise(ii,kk).eval(xn);
    end
    
    % do the PSD/FFT of the noise time series and calculate the inverse cross-spectrum matrix
    [S, invS] = performPSD(noise_ts(:,kk), Nout, Navs, olap, trim, win, freqs, fs, dtrnd, f);
     
    % Get chi2(f)
    chi2 = real(utils.math.ctmult(hmat(kk).hs, utils.math.mult(invS, hmat(kk).hs)));

    % Get L(f)
    Lf{kk} = log(S)./2 + chi2;
    
    % L: Sum over frequencies
    logLexp(kk) = -sum(Lf{kk}(k0:end));
    
    % Sum experiments
    L = L + logLexp(kk);
    
    snr  = snr + logLexp(kk)./Navs;
    
  end
  
  % Set output
  varargout{1} = L;
  varargout{2} = snr;
  varargout{3} = logLexp;
  %varargout{3} = Navs.*snrexp(kk);
  varargout{4} = Lf;
  
end

%
% Perform the PSD on the noise time-series and take the inverse
%
function [S, invS] = performPSD(ts, Nout, Navs, olap, trim, win, freqs, fs, dtrnd, f)
  
  for ii = 1:Nout
    for jj = 1:Nout
      if ii==jj
        [data, nf] = utils.math.psd(ts.hs(:,ii), Navs, olap, trim, win, freqs, fs, dtrnd, [], [], []);
        S(:,ii,jj) = interp1(nf, data, f, 'linear', 'extrap');
      else
        [data, nf] = utils.math.cpsd(ts.hs(:,ii), ts.hs(:,jj), Navs, olap, trim, win, freqs, fs, dtrnd, [], [], []);
        S(:,ii,jj) = interp1(nf, data, f, 'linear', 'extrap');
        S(:,jj,ii) = conj(S(:,ii,jj));
      end
    end
  end
  
  % Inverse
  invS = takeInv(S, Nout);
  
end

%
% Take the inverse of the spectrum matrix
%
function invA = takeInv(A, Nout)
  
  if Nout == 1
    invA = 1./A;
  else
    % Calculate the determinant
    determinant = calcDet(A, Nout);
    for ii = 1:Nout % raw index
      for jj = 1:Nout % column index
        % ij Minor of A
        AM         = A;
        AM(:,ii,:) = [];
        AM(:,:,jj) = [];
        % cofactor
        C(:,ii,jj) = calcDet(AM, Nout).*((-1)^(ii+jj));
      end
    end
    % get the transpose of cofactors matrix
    invA = zeros(size(A,1), Nout, Nout);
    for ii = 1:Nout
      for kk = 1:Nout
        invA(:,kk,ii) = C(:,ii, kk)./determinant;
      end
    end
  end
  
end

%
% Calculate the determinant
%
function determinant = calcDet(A, Nout)
  
  switch Nout
    case 1
      determinant = A;
    case 2
      determinant = A(:,1,1) .* A(:,2,2) - A(:,2,1) .* A(:,1,2);
    otherwise
      dmod_minor = zeros(length(A(:,1,1)), Nout); %eval(sprintf('%s.initObjectWithSize(1,cl);', class(objmat)));
      
      % Cache these objects not to produce them iteratively
      for jj = 1:Nout
        Amod = A;
        Amod(:,1,:) = [];
        Amod(:,:,jj) = [];
        dmod_minor(:,jj) = A(:,1,jj) .* calcDet(Amod) * (-1)^(jj+1);
      end
      % sum over elements
      determinant = dmod_minor(:,1);
      for kk = 2:numel(dmod_minor(1,:))
        determinant = determinant + dmod_minor(:,kk);
      end
  end
  
end
  
% END