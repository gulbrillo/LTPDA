% TEST_FIR_FILTER test FIR filtering of AO class.
%
% M Hewitson 11-05-07
%
% $Id$
%
function test_fir_filter()
  
  
  % Make some data
  nsecs = 100;
  fs    = 100;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*2*t)');
  a1 = ao(pl)
  
  % Make filter
  
  pl = plist(...
    'type', 'lowpass', ...
    'order', 32, ...
    'fs', 100, ...
    'fc', 30);
  f  = mfir(pl)
  
  % Filter data
  
  pl = plist('gdoff', 1);
  
  a2 = filter(a1, f);
  a3 = filter(a2, f);
  
  % Plot
  
  [hf, ha, hl] = iplot([a1 a2 a3], plist('XRanges', [0 1]));
  set(hl(1), 'Marker', 'o');
  set(hl(2), 'Marker', 'x');
  set(hl(3), 'Marker', '+');
  
  [hf, ha, hl] = iplot([a1 a2 a3], plist('XRanges', [99 100]));
  set(hl(1), 'Marker', 'o');
  set(hl(2), 'Marker', 'x');
  set(hl(3), 'Marker', '+');
  
  % Make spectra
  pl   = plist('Nfft', '10*fs');
  a1xx = psd(a1, pl);
  a2xx = psd(a2, pl);
  a3xx = psd(a3, pl);
  
  iplot([a1xx,a2xx,a3xx])
  
  close all
end


