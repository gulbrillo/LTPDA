% ltpda_spsd smooths a spectrum.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ltpda_spsd smooths a spectrum.
%
% CALL:        [freqsOut, pow, nFreqs, sigmaP, sumMat] = ltpda_spsd(freqs, pow, linCoef, logCoef, sumMat,nFreqs)
%
% INPUTS:      freqsOut - frequency vector, can be left empty
%              pow     - power spectrum (density)
%              nFreqs  - frequency intervals used to derive averages
%              linCoef, logCoef
%                      - values to use to scale the smoothing
%                        averaging filter. It will be in linCoef.NBins^logCoef.
%                        logCoef should be 2/3 for PSD and 4/5 for PSD data
%                        which is later plotted in ASD scale.
%              mode   - 'keepFrequencies' convoles using a filter, leaving all
%                        frequencies but they are correlated
%                       'removeFrequencies' convoles using a filter, leaving
%                        only data at some uncorrelated frequencies
%                       'addUp' like above, but sums up instead of takin a
%                        mean value.
%
% OUTPUTS:     freqs, pow : output frequency and power vector.
%
% <a href="matlab:web(ao.getInfo('spsd').tohtml, '-helpbrowser')">Parameter Sets</a>
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = ltpda_spsd(varargin)
  %% collecting inputs
  freqs = varargin{1};
  pow = varargin{2};
  L = length(pow);
  pow = reshape(pow, [L, 1]);
  freqs = reshape(freqs, [numel(freqs), 1]);
  linCoef = varargin{3};
  logCoef = varargin{4};
  if nargin >4
    % optional inputs include the averaging matrix
    sumMat = varargin{5};
    nFreqs = varargin{6};
  else
    % averaging matrix must be computed from input data
    [nFreqs, sumMat] = getMatrix(L, linCoef, logCoef);
  end
  %% evaluating output
  computeVar = nargout>=4;
  computeFreqs = ~isempty(freqs);
  sumPow = sumMat * pow; % power sums
  powOut = sumPow ./ nFreqs; % power average
  if computeFreqs
    freqsOut = (sumMat * freqs) ./ nFreqs; % correponding mean frequency
  else
    freqsOut = [];
  end
  if computeVar
    nBinsEff = sumPow.^2 ./ (sumMat * pow.^2) ; % number of Chi2 variables for STD
  else
    nBinsEff = [];
  end
  
  %% allocating output
  varargout = {freqsOut, powOut, nFreqs, nBinsEff, sumMat};
  
end


function [nFreqs, sumMat] = getMatrix(L, linCoef, logCoef)
  %% initializing loop
  iAvg = 1;
  iMin = 1;
  idxAvg = zeros(1,L); % index of corresponding average
  widths = ceil(linCoef):ceil(linCoef * L^logCoef + 2); % proposed width of averagin filter
  iMaxForWidths = min(L, floor( (widths./linCoef).^(1/logCoef) + widths-1 ) ); % last sample to be processed with a given filter width
  lastWidth = find(iMaxForWidths==L,1,'first'); % width when the end fo te freq. series is reached
  
  %% 1st loop on filter width
  for iiWidth = 1:lastWidth
    NAverages = ceil( (iMaxForWidths(iiWidth)-iMin+1) / widths(iiWidth) ); % number of times the width avgWidth is going to be used
    for kk=1:NAverages
      %% second loop on filter iteration
      iMax = min(L, iMin + widths(iiWidth)-1); % last sample for current average
      idxAvg(iMin:iMax) = ones(1,iMax-iMin+1) * iAvg; % index of corresponding average
      iMin = iMax + 1;
      iAvg = iAvg + 1;
    end
  end

  %% creating output data  
  sumMat = sparse(idxAvg, 1:L, ones(1,L));
  nFreqs = sumMat*ones(L,1);
  
end