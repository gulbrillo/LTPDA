% UTILS.MATH.CPSD: Pure Matlab function that performs the CPSD using LTPDA machinery
%
% Used solely in calculations of the logarithmic log-likelihood function, and 
% should be hidden from the user.
%
% NK 2015
%
function [spec, freqs] = cpsd(a, b, navs, olap, trim, win, flims, fs, detrendOrder, t0, toffset, segs)
  
  % Check lengths
  if length(a) ~= length(b)
    error('### Something is wrong, the length of the data is not the same to perform the CPSD... ')
  end
  
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
  spec = averageFFTs(a, b, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder, nfft, fs, t0, toffset, segs);

  % Compute frequencies
  freqs = psdfreqvec('npts', nfft,'Fs', fs, 'Range', 'half');
  
  % split in frequency
  [spec, freqs] = splitInFreq(spec, freqs, flims);
    
end

%
% compute FFT/PSD
%
function Mk = averageFFTs(x, y, winVals, nSegments, segmentStarts, segmentEnds, detrendOrder, nfft, fs, t0, toffset, segs)
  
  % Initialise
  Mk = 0; 
  
  % Loop over the segments
  for ii = 1:nSegments
    if isempty(segs)
      XX = x(segmentStarts(ii):segmentEnds(ii));
      YY = y(segmentStarts(ii):segmentEnds(ii));
    else
      t   = tsdata.createTimeVector(fs, numel(x)/fs) + t0.double + toffset;
       %%% Compute the start/end time
      ts  = segs(ii).getStartT.double;
      te  = segs(ii).getEndT.double;
      idx = t >= ts & t < te;
      
      XX = x(idx);

    end
      % Detrend if desired
      if detrendOrder < 0
        segX = XX;
        segY = YY;
      else
        [segX, ~] = ltpda_polyreg(XX, detrendOrder);
        [segY, ~] = ltpda_polyreg(YY, detrendOrder);
      end

    % Compute FFT
    S = cFFT(segX, segY, winVals, nfft);
    % Welford's algorithm for updating mean
    if ii == 1
      Mk = S;
    else
      delta = S - Mk;
      Mk    = Mk + delta/ii;
    end
  end
  % abs(Qxx.*conj(Sxxk - Mnxx))
  
end

%
% Compute the FFT of the signals
%
function Sxx = cFFT(x, y, win, nfft)
  
  % window data
  xwin = x.*win;
  ywin = y.*win;
  
  % take fft
  X = fft(xwin, nfft);
  Y = fft(ywin, nfft);
  
  % Compute scale factor to compensate for the window power
  K = win'*win;
  
  % Apply scale
  Sxx = X.*conj(Y)/K;

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