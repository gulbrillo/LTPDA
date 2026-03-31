% WOSA implements Welch's overlaped segmented averaging algorithm with
% segment detrending and variance estimation.
% 
% [pxx, f, info] = wosa(x,type,pl)
% [pxx, f, info] = wosa(x,y,type,pl)
%
% INPUTS:      x    - input analysis objects
%              y    - input analysis objects
%              type - type of estimation:
%                       'psd'      - compute Power Spectral Denstiy (PSD)
%                       'cpsd'     - compute cross-spectral density
%                       'tfe'      - estimate transfer function between inputs
%                       'mscohere' - estimate magnitude-squared cross-coherence
%                       'cohere'   - estimate complex cross-coherence
%              pl   - input parameter list
%
% PARAMETERS: 'Win'   - a specwin window object [default: taken from user preferences]
%             'Olap' - segment percent overlap [default: taken from window function]
%             'Nfft'  - number of samples in each fft [default: length of input data]
%             'Scale' - one of
%                                'ASD' - amplitude spectral density
%                                'PSD' - power spectral density [default]
%                                'AS'  - amplitude spectrum
%                                'PS'  - power spectrum
%                       * applies only to spectrum 'Type' 'psd'
%             'Order' - order of segment detrending
%                        -1 - no detrending
%                         0 - subtract mean [default]
%                         1 - subtract linear fit
%                         N - subtract fit of polynomial, order N
%

function varargout = wosa(varargin)
  import utils.const.*
  
  % Process inputs
  if nargin == 3
    a  = varargin{1};
    esttype = varargin{2};
    pl = varargin{3};
    inunits = a.data.yunits;
    L = numel(a.data.getY);
  else
    a  = varargin{1};
    b  = varargin{2};
    esttype = varargin{3};
    pl = varargin{4};
    if a.data.fs ~= b.data.fs
      error('The two time-series have different sample rates.');
    end
    inunits = b.data.yunits / a.data.yunits;
    L = min(numel(a.data.getY), numel(b.data.getY));
  end
  
  % Parse inputs
  mask         = find_core(pl, 'mask');
  win          = find_core(pl, 'Win');
  nfft         = find_core(pl, 'Nfft');
  olap         = find_core(pl, 'Olap');
  scale        = find_core(pl, 'scale');
  xOlap        = round(olap*nfft/100); % Should this be round or floor?
  detrendOrder = find_core(pl, 'order');
  fs           = a.data.fs;
  winVals      = win.win.'; % because we always get a column from ao.y
  
  % Compute segment details
  
  nSegments = fix((L - xOlap) ./ (nfft - xOlap));
  utils.helper.msg(msg.PROC3, 'N segment: %d', nfft);
  utils.helper.msg(msg.PROC3, 'N overlap: %d', xOlap);
  utils.helper.msg(msg.PROC3, 'N segments: %d', nSegments);
  
  % Compute start and end indices of each segment
  segmentStep = nfft - xOlap;
  segmentStarts = 1 : segmentStep : nSegments*segmentStep;
  segmentEnds   = segmentStarts + nfft - 1;
  
  if isempty(mask)
    mask = ones(1, nSegments);
  end

  if length(mask) ~= nSegments
    error('Please give a mask vector which is the same length as the number of segments (in this case %d)', nSegments);
  end
  
  % ensure we have logicals here
  mask = logical(mask);
  
  % filter the segments according to the mask
  segmentStarts = segmentStarts(mask);
  segmentEnds   = segmentEnds(mask);
  nSegments     = numel(segmentStarts);
  
  % Estimate the averaged periodogram for the desired quantity. These
  % routines use a running average whereas MATLAB's welch does a full sum
  % and then divides by nSegments.
  
  switch lower(esttype)
    case 'psd'
      [Sxx, Svxx] = psdPeriodogram(a, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder);
    case 'cpsd'
      [Sxx, Svxx] = cpsdPeriodogram(a, b, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder);
    case {'mscohere', 'cohere', 'tfe'}
      [Sxx, Sxy, Syy] = tfePeriodogram(a, b, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder);
    otherwise
      error('Unknown estimation type %s', esttype);
  end

  % Scale to PSD
  switch lower(esttype)
    case {'psd','cpsd'}
      [P, Pvxx] = scaleToPSD(Sxx, Svxx, nfft, fs);
      % For the errors, the 1/nSegments factor should come after welchscale
      % if we don't want to apply sqrt() to it. We correct for that here.
      % It is only needed for 'asd','as' in psd/cpsd, the other cases go
      % always through 'PSD'.
      if (strcmpi(scale,'PSD') || strcmpi(scale,'PS'))
        dP = Pvxx;
      elseif (strcmpi(scale,'ASD') || strcmpi(scale,'AS'))
        dP = Pvxx / nSegments;
      else
        error('### Unknown scale')
      end
    case 'tfe'
      % Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
      % Also, corresponding freq vector and freq units.
      % In the Cross PSD, the frequency vector and xunits are not used.
      Pxx = scaleToPSD(Sxx, [], nfft, fs);
      Pxy = scaleToPSD(Sxy, [], nfft, fs);
      Pyy = scaleToPSD(Syy, [], nfft, fs);
      % mean and std
      P = Pxy ./ Pxx; % Txy
      if nSegments == 1
        dP =[];
      else
        dP = (nSegments/(nSegments-1)^2)*(Pyy./Pxx).*(1 - (abs(Pxy).^2)./(Pxx.*Pyy));
      end
    case 'mscohere'
      % Magnitude Square Coherence estimate.
      % Auto PSD for 2nd input vector. The freq vector & xunits are not
      % used.
      Pxx = scaleToPSD(Sxx, [], nfft, fs);
      Pxy = scaleToPSD(Sxy, [], nfft, fs);
      Pyy = scaleToPSD(Syy, [], nfft, fs);
      % mean and std
      P = (abs(Pxy).^2) ./ (Pxx.*Pyy); % Magnitude-squared coherence
      dP = (2*P/nSegments) .* (1-P).^2;
    case 'cohere'
      % Complex Coherence estimate.
      % Auto PSD for 2nd input vector. The freq vector & xunits are not
      % used.
      Pxx = scaleToPSD(Sxx, [], nfft, fs);
      Pxy = scaleToPSD(Sxy, [], nfft, fs);
      Pyy = scaleToPSD(Syy, [], nfft, fs);
      P = Pxy./sqrt(Pxx.*Pyy); % Complex coherence
      dP = (2*abs(P)/nSegments) .* (1-abs(P)).^2;
  
  end
  
  % Compute frequencies
  freqs = psdfreqvec('npts', nfft, 'Fs', fs, 'Range', 'half').';
  
  % Scale to required units
  [Pxx, dP, info] = utils.math.welchscale(P, dP, winVals, fs, scale, inunits);
  info.navs = nSegments;
  info.win  = win;
  if nSegments == 1
    dev = [];
  else
    dev = sqrt(dP);
  end
  
  % Set outputs
  varargout = {Pxx, freqs, info, dev};
    
end

% scale averaged periodogram to PSD
function [Pxx, Pvxx] = scaleToPSD(Sxx, Svxx, nfft, fs)
  
  % Take 1-sided spectrum which means we double the power in the
  % appropriate bins
  if rem(nfft,2),
    indices = 1:(nfft+1)/2;  % ODD
    Sxx1sided = Sxx(indices,:);
    % double the power except for the DC bin
    Sxx = [Sxx1sided(1,:); 2*Sxx1sided(2:end,:)];  
    if ~isempty(Svxx)
      Svxx1sided = Svxx(indices,:);
      Svxx = [Svxx1sided(1,:); 4*Svxx1sided(2:end,:)];
    end
  else
    indices = 1:nfft/2+1;    % EVEN
    Sxx1sided = Sxx(indices,:);
    % Double power except the DC bin and the Nyquist bin
    Sxx = [Sxx1sided(1,:); 2*Sxx1sided(2:end-1,:); Sxx1sided(end,:)];
    if ~isempty(Svxx)
      Svxx1sided = Svxx(indices,:); % Take only [0,pi] or [0,pi)
      Svxx = [Svxx1sided(1,:); 4*Svxx1sided(2:end-1,:); Svxx1sided(end,:)];
    end
  end

  % Now scale to PSD
  Pxx   = Sxx ./ fs;
  Pvxx  = Svxx ./ fs^2;
  
end

% compute tfe
function [Sxx, Sxy, Syy] = tfePeriodogram(x, y, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder)
  
  nfft = segmentEnds(1);
  Sxx = zeros(nfft,1); % Initialize Sxx
  Sxy = zeros(nfft,1); % Initialize Sxy
  Syy = zeros(nfft,1); % Initialize Syy
  % loop over segments
  for ii = 1:nSegments
    if detrendOrder < 0
      xseg = x.data.getY(segmentStarts(ii):segmentEnds(ii));
      yseg = y.data.getY(segmentStarts(ii):segmentEnds(ii));
    else
      [xseg, coeffs] = ltpda_polyreg(x.data.getY(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
      [yseg, coeffs] = ltpda_polyreg(y.data.getY(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
    end

    % Compute periodograms
    Sxxk = wosa_periodogram(xseg, [], winVals, nfft);
    Sxyk = wosa_periodogram(yseg, xseg, winVals, nfft);
    Syyk = wosa_periodogram(yseg, [], winVals, nfft);
      
    Sxx = Sxx + Sxxk;
    Sxy = Sxy + Sxyk;
    Syy = Syy + Syyk;
    % don't need to be divided by k because only rations are used here
  end
  
end

% compute cpsd
function [Sxx, Svxx] = cpsdPeriodogram(x, y, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder)
  
  variance_RI = true;
  
  Mnxx = 0;
  Mn2xx = 0;
  Mnxx_R = 0;
  Mnxx_I = 0;
  Mn2xx_R = 0;
  Mn2xx_I = 0;
  
  nfft = segmentEnds(1);
  for ii = 1:nSegments
    if detrendOrder < 0
      xseg = x.data.getY(segmentStarts(ii):segmentEnds(ii));
      yseg = y.data.getY(segmentStarts(ii):segmentEnds(ii));
    else
      [xseg, coeffs] = ltpda_polyreg(x.data.getY(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
      [yseg, coeffs] = ltpda_polyreg(y.data.getY(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
    end
    
    % Compute periodogram
    Sxxk = wosa_periodogram(xseg, yseg, winVals, nfft);
    Sxxk_R = real(Sxxk);
    Sxxk_I = imag(Sxxk);
    
    % Welford's algorithm to update mean
    Qxx = Sxxk - Mnxx;
    Mnxx = Mnxx + Qxx/ii;
    
    % Welford's algorithm to update variance
    Mn2xx = Mn2xx + abs(Qxx .* conj(Sxxk - Mnxx));

    % Welford's algorithm to update variance of real part
    Qxx_R = Sxxk_R - Mnxx_R;
    Mnxx_R = Mnxx_R + Qxx_R/ii;
    Mn2xx_R = Mn2xx_R + Qxx_R .* (Sxxk_R - Mnxx_R);
    
    % Welford's algorithm to update variance of imaginary part
    Qxx_I = Sxxk_I - Mnxx_I;
    Mnxx_I = Mnxx_I + Qxx_I/ii;
    Mn2xx_I = Mn2xx_I + Qxx_I .* (Sxxk_I - Mnxx_I);

  end
  
  Sxx = Mnxx;
  
  if nSegments == 1
    Svxx = [];
  else
    if variance_RI
      Svxx = complex(Mn2xx_R, Mn2xx_I)/(nSegments-1)/nSegments;
    else
      Svxx = Mn2xx/(nSegments-1)/nSegments;
    end
  end
  
  
end

% compute psd
function [Sxx, Svxx] = psdPeriodogram(x, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder)
  
  Mnxx = 0; 
  Mn2xx = 0;
  nfft = segmentEnds(1) - segmentStarts(1) + 1;
  % Loop over the segments
  for ii = 1:nSegments
    % Detrend if desired
    if detrendOrder < 0
      seg = x.data.getY(segmentStarts(ii):segmentEnds(ii));
    else
      [seg, coeffs] = ltpda_polyreg(x.data.getY(segmentStarts(ii):segmentEnds(ii)), detrendOrder);
    end
    % Compute periodogram
    Sxxk = wosa_periodogram(seg, [], winVals, nfft);
    % Welford's algorithm for updating mean and variance
    if ii == 1
      Mnxx = Sxxk;
    else
      Qxx = Sxxk - Mnxx;
      Mnxx = Mnxx + Qxx/ii;
      Mn2xx = Mn2xx + Qxx .* (Sxxk - Mnxx);
    end
  end
  
  Sxx = Mnxx;
  
  if nSegments == 1
    Svxx = [];
  else
    Svxx = Mn2xx/(nSegments-1)/nSegments;
  end
  
end

% Scaled periodogram of one or two input signals
function Sxx = wosa_periodogram(x, y, win, nfft)
  
  % window data
  xwin = x .* win;
  isCross = false;
  if ~isempty(y)
    ywin = y .* win;
    isCross = true;
  end
  
  % take fft
  X = fft(xwin, nfft);
  if isCross
    Y = fft(ywin, nfft);
  end
  
  % Compute scale factor to compensate for the window power
  K = win' * win;
  
  % Compute scaled power
  Sxx = X .* conj(X) / K;
  if isCross,
    Sxx = X .* conj(Y) / K;
  end  
  
end
