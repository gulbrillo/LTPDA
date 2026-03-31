% UTILS.MATH.PSD: Pure Matlab function that performs the PSD using LTPDA machinery
%
% Used solely in calculations of the logarithmic log-likelihood function, and 
% should be hidden from the user.
%
% NK 2015
%
function [spec, freqs] = psd(a, navs, olap, trim, win, flims, fs, detrendOrder, t0, toffset, segs)
  
  % Get length
  if isempty(segs)
    L = numel(ao.split_samples_core(a,[trim(1)./fs + 1, numel(a) + trim(2)./fs]));

    % Compute the number of segments
    obj_len = L;

    overlap = olap/100; % overlap
    L       = round(obj_len/(navs*(1-overlap) + overlap));

    % Checks it will really obtain the correct answer.
    % This is needed to cope with the need to work with integers
    while fix((obj_len-round(L*overlap))/(L-round(L*overlap))) < navs
      L = L - 1;
    end

    nfft = L;
    
    % Compute segment details
    nSegments = navs;
  
  else
    L         = numel(ao.split_samples_core(a, [1, segs(1).getNsecs]));
    nfft      = L;
    nSegments = numel(segs);
  end
  
  % Parse inputs
  winVals      = specwin(win, L).win.';
  xOlap        = round(olap*nfft/100); % Should this be round or floor?
  
  % Compute start and end indices of each segment
  segmentStep   = nfft-xOlap;
  segmentStarts = 1:segmentStep:nSegments*segmentStep;
  segmentEnds   = segmentStarts+nfft-1;
  
  % Estimate the averaged periodogram for the desired quantity. 
  spec = averageFFTs(a, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder, nfft, fs, t0, toffset, segs);

  % Scale to PSD
  spec = scale(spec, nfft, fs);
  
  % Compute frequencies
  freqs = psdfreqvec('npts', nfft,'Fs', fs, 'Range', 'half');
  
  % split in frequency
  [spec, freqs] = splitInFreq(spec, freqs, flims);
    
end

%
% compute FFT/PSD
%
function Mk = averageFFTs(x, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder, nfft, fs, t0, toffset, segs)
  
  % Initialise
  Mk = 0; 
  
  % Loop over the segments
  for ii = 1:nSegments
    if isempty(segs)
      Y = x(segmentStarts(ii):segmentEnds(ii));
    else
      t   = tsdata.createTimeVector(fs, numel(x)/fs) + t0.double + toffset;
       %%% Compute the start/end time
      ts  = segs(ii).getStartT.double;
      te  = segs(ii).getEndT.double;
      idx = t >= ts & t < te;
      
      Y = x(idx);

    end
      % Detrend if desired
      if detrendOrder < 0
        seg = Y;
      else
        [seg, ~] = ltpda_polyreg(Y, detrendOrder);
      end

    % Compute FFT
    X = doFFT(seg, winVals, nfft);
    % Welford's algorithm for updating mean
    if ii == 1
      Mk = X;
    else
      delta = X - Mk;
      Mk    = Mk + delta/ii;
    end
  end
  
end

%
% Compute the FFT of the signals
%
function Sxx = doFFT(x, win, nfft)
  
  % window data
  xwin = x.*win;
  
  % take fft
  X = fft(xwin, nfft);
  
  % Compute scale factor to compensate for the window power
  K = win'*win;
  
  % Apply scale
  Sxx = X.*conj(X)/K;

end

%
% scale averaged periodogram to PSD
%
function S = scale(S_in, nfft, fs)
  
  % Take 1-sided spectrum which means we double the power in the
  % appropriate bins
  if rem(nfft,2),
    indices = 1:(nfft+1)/2;  % ODD
    Sxx1sided = S_in(indices,:);
    % double the power except for the DC bin
    S_in = [Sxx1sided(1,:); 2*Sxx1sided(2:end,:)];  
  else
    indices = 1:nfft/2+1;    % EVEN
    Sxx1sided = S_in(indices,:);
    % Double power except the DC bin and the Nyquist bin
    S_in = [Sxx1sided(1,:); 2*Sxx1sided(2:end-1,:); Sxx1sided(end,:)];
  end

  % Now scale to PSD
  S = S_in ./ fs;
  
end

%
% Define the samples and split in frequency
%
function [spec, f] = splitInFreq(spec, freqs, flims)
  
  [~, idx(1)] = min(abs(freqs - flims(1)));
  [~, idx(2)] = min(abs(freqs - flims(2)));

  spec = ao.split_samples_core(spec, idx);
  f    = ao.split_samples_core(freqs, idx);
  
end

% END