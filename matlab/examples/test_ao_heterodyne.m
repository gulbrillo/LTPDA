% Tests for ao/heterodyne
%
% $Id$
%

function test_ao_heterodyne
  %% produce input signal
  
  fs = 10;
  nsecs = 1000;
  amplitude = 1e-3;
  noise = 1e-6;
  fmod = 0.1;
  yunits = 'V';
  
  % carrier
  h = ao(plist('waveform', 'sine', 'f', fmod, 'a', 1, 'fs', fs, 'nsecs', nsecs, 'yunits', yunits));
  % signal
  s = ao(plist('waveform', 'sine', 'f', 5e-3, 'a', 1, 'fs', fs, 'nsecs', nsecs));
  % modulate the carrier
  m = h .* s;
  % add noise
  n = ao(plist('waveform', 'noise', 'nsecs', nsecs, 'fs', fs, 'sigma', noise, 'yunits', yunits));
  
  a1 = m + n;
  
  %% demodulate
  b1_cos = a1.heterodyne(plist('f0', fmod, 'bw', fmod, 'quad', 'cos'));
  b1_sin = a1.heterodyne(plist('f0', fmod, 'bw', fmod, 'quad', 'sin'));
  
  iplot(s, b1_cos, b1_sin, plist('linestyles', {'-','none','none'}, 'markers', {'none','+','+'}));
  
  %% demodulate without downsampling
  b1_cos = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'bw', fmod, 'quad', 'cos'));
  b1_sin = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'bw', fmod, 'quad', 'sin'));
  
  iplot(s, b1_cos, b1_sin);
  
  %% demodulate without downsampling and low pass filtering
  b1_cos = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'lp', 'no', 'bw', fmod, 'quad', 'cos'));
  b1_sin = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'lp', 'no', 'bw', fmod, 'quad', 'sin'));
  
  iplot(s, b1_cos, b1_sin);
  
  %% demodulate without downsampling, but with low pass filtering from user input
  filt = miir(plist('type', 'lowpass', 'order', 2, 'fc', 0.2*fmod, 'fs', a1.data.fs));
  b1_cos = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'lp', 'no', 'bw', fmod, 'quad', 'cos', 'filter', filt));
  b1_sin = a1.heterodyne(plist('f0', fmod, 'ds', 'no', 'lp', 'no', 'bw', fmod, 'quad', 'sin', 'filter', filt));
  
  iplot(s, b1_cos, b1_sin);
  
  close all
  
end
