% FFTDELAY_CORE applies a delay to a timeseries using the FFT/IFFT method
%
% CALL:  y = fftdelay_core(x,tau,fs)
%
% INPUTS: x   -  input timeseries (double)
%         tau -  delay (double)
%         fs  - sampling frequency (default to 1Hz)
% OUTPUTS: y - delayed timeseries (double)
%

function varargout = fftdelay_core(x,tau,fs)
  
  % set default sampling frequency
  if nargin <3, fs = 1; end
  
  % store size for later
  Sin = size(x);
  
  % zeropad
  Npad = Sin(1) - 1;
  x = cat(1,x,zeros(Npad,Sin(2)));
  
  % fft shift
  %x = fftshift(x);
  Nfft = size(x,1);
  
  % take one-sided fft of input
  xf = fft(x,[],1);
  xf = xf(1:floor(Nfft/2)+1,:);
  
  % get frequency vector
  f = (0:floor(Nfft/2))'.*fs./Nfft;
  
  % compute delay transfer funciton
  tfd = exp(-2*pi*1i*tau*f);
  
  % compute output fft
  yf = (tfd*ones(1,Sin(2))).*xf;
  
  % take symmetric one-sided IFFT
  yf1 = yf(1:end,:);
  yf2 = conj(yf(end:-1:2,:));
  yf = [yf1; yf2];
  y = ifft(yf,'symmetric');
  
  % trim
  y(Npad+2:end,:) = [];
  
  % reshape
  y = reshape(y,Sin);
  
  % set output
  varargout{1} = y;
  
end





