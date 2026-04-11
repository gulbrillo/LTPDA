% FREQCORR Compute correlation between frequency bins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FREQCORR Compute correlation between frequency bins of a spectral
% estimation given the data window
% 
% CALL 
% 
% Gf = utils.math.freqCorr(w,eta,T)
% 
% INPUT
% 
% - w, window samples, Nx1 double, N must be the effective length of the
% segments used for spectral estimation. E.g. For a periodogram N is equal
% to the length of the data series. For a WOSA estimation N is the length
% of each averaging segment.
% - eta, frequency lag in Hz, 1x1 double
% - T, sampling time in seconds, 1x1 double
% 
% REFERENCES
% 
% D. B. Percival and A. T. Walden, Spectral Analysis for Physical
% Applications (Cambridge University Press, Cambridge, 1993) p 231.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function R = freqCorr(w,eta,T)
  
  Ns = numel(w);
  % willing to work with columns
  [nn,mm] = size(w);
  if nn<mm
    w = w.';
  end
  % make suqre integrable
  a = sqrt(sum(w.^2));
  w = w./a;

  t = 1:Ns;

  ww = w.*w;
  hh = exp(-1i.*2.*pi.*t.*T.*eta)*ww;
  R = abs(hh)^2;
  

end