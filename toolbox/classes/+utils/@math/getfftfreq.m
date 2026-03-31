% GETFFTFREQ: get frequencies for fft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Luigi Ferraioli 04-02-2011
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = getfftfreq(nfft,fs,type)
  switch lower(type)
    case 'plain'
      f = (0:nfft-1).*fs./nfft;
    case 'one'
      f = (0:floor(nfft/2)).*fs./nfft;
    case 'two'
      if rem(nfft,2) % odd number of data
        f = fftshift([0:floor(nfft/2) -(floor(nfft/2)):-1].*fs./nfft);
      else % even number of data
        f = fftshift([0:floor(nfft/2)-1 -floor(nfft/2):-1].*fs./nfft);
      end
  end
end