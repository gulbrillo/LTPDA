%
% 1-sided fft_core function
%
function ft = fft_1sided_core(x)
  
  nfft = length(x);
  ft   = fft(x);
  ft   = ft(1:floor(nfft/2)+1);
  
end