%
% 1-sided ifft odd nfft core function
%
function y = ifft_1sided_odd_core(x, type)
  
  y1 = x(1:end);
  y2 = conj(x(end:-1:2));
  
  if size(y1,1)==1 % raw
    y = [y1 y2];
  else
    y = [y1;y2];
  end
  
  y  = ifft(y, type);
  
  % Keep the data shape if the input AO
  if size(x, 1) == 1
    y = y.';
  end
  
end