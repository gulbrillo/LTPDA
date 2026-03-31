%
% 1-sided fft_core function
%
function y = ifft_2sided_core(x, type)
  
  y = ifftshift(x);
  
  y = ifft(y, type);
  % Keep the data shape if the input AO
  if size(x, 1) == 1
    y = y.';
  end
  
end