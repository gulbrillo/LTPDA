% DFT Compute discrete fourier transform at a given frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DFT Compute discrete fourier transform at a given frequency
% It is defined as 
% X(f) = T*sum(x(t)*exp(-1i.*2.*pi.*f.*T.*t))|t=0,...,N-1
% where T is the sampling time
% 
% CALL 
% 
% Gf = utils.math.dft(gt,f,T)
% 
% INPUT
% 
% - gt, input data series, Nx1 double
% - f, a frequency point in Hz, 1x1 double
% - T, sampling time in seconds, 1x1 double
% 
% REFERENCES
% 
% D. B. Percival and A. T. Walden, Spectral Analysis for Physical
% Applications (Cambridge University Press, Cambridge, 1993) p 108.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Gf = dft(gt,f,T)
  
  [nn,mm] = size(gt);
  if nn<mm % willing to work with columns
    gt = gt.';
  end
  N = numel(gt);
  t = 0:N-1;
  
  ar = exp(-1i.*2.*pi.*f.*T.*t);
  
  Gf = T*(ar*gt);


end