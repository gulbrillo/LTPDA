%
% A core utils function, to perform PZ model filtering to
% a time series.
%
function z = filtpz(x, pole, Gain)
  
  N    = length(x);
  x    = [x ; zeros(N - 1,1)];
  nfft = length(x);
  ft   = fft(x);
  f    = utils.math.getfftfreq(nfft, 1, 'one');
  ft   = ft(1:floor(nfft/2)+1);
  f    = reshape(f, size(ft));

  re = 1;
  im = f./pole;
  r  = 1./complex(re, im);
  r  = r .* exp(-2*pi*f*1i);

  ft = ft.*r;
  
  y1 = ft(1:end);
  y2 = conj(ft(end:-1:2));

  y = [y1;y2];

  y = ifft(y, 'symmetric');

  z = Gain.*y(1:N);
  
end