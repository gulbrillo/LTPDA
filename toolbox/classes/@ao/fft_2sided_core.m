%
% 2-sided fft_core function
%
function ft = fft_2sided_core(x)
  
  ft   = fft(x);
  ft   = fftshift(ft);
  
end