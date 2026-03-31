% BLWHITENOISE return a band limited gaussian distributed white noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BLWHITENOISE return a band limited Gaussian distributed
% white noise
%
% CALL:       wn = blwhitenoise()
%
% INPUTS:     npts  - number of data points in the series. Note, number of
%                     seconds is npts*fs
%             fs    - sampling frequency
%             fl    - lower bandwidth frequency
%             fh    - higher bandwidth frequency
%
% OUTPUTS:    wn - band limited gaussian white noise
% 
% REFERENCES:
% 
% [1] Kafadar, K., Gaussian white-noise generation for digital signal
% synthesis. IEEE Transactions on Instrumentation and Measurement IM-35(4),
% 492-495, 1986.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Xt = blwhitenoise(npts,fs,fl,fh)
  
  % generate linear spaced frequency vactor for fft
  f = (0:floor(npts/2)).*fs./npts;
  f = f';
  nf = length(f);
  
  % amplitude vector
  amp = zeros(nf,1);
  
  % phase vactor
  phs = zeros(nf,1);
  
  % select frequency range
  if fh>fs/2
    fh = fs/2;
  end
  if fl<0
    fl = 0;
  end
  
  idxl = f>=fl;
  idxh = f<=fh;
  idx = idxl&idxh;
  n1s = sum(idx);
  
  phs(idx,1) = -pi + (2*pi).*rand(n1s,1);
  phs(1,1) = 0;
  phs(end,1) = 0;
  amp(idx,1) = sqrt(npts);
  amp(1,1) = 0;
  amp(end,1) = 0;
  
  % get final random phase and constant amplitude
  phs = [phs;-1.*flipud(phs(2:end-1))];
  amp = [amp;flipud(amp(2:end-1))];
  
  % fft signal
  Xf = amp.*(cos(phs)+1i.*sin(phs));
  
  % time domain signal
  Xt = ifft(Xf);
  
end
% END

