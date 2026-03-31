% Test ao.pwelch functionality.
%
% M Hewitson 08-05-08
%
% $Id$
%
function test_ao_pwelch()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist(...
    'nsecs', nsecs, ...
    'fs', fs, ...
    'tsfcn', '(t.^2 - (t.^3)/10) + sin(2*pi*7*t) + randn(size(t))', ...
    'yunits', 'fN');
  
  a1 = ao(pl);
  
  % Make PSDs
  Nfft = 2*fs;
  win = specwin('Hanning', Nfft);
  pl  = plist('Nfft', '2*fs', 'Win', win, 'Order', 2, 'Scale', 'ASD');
  a2 = psd(a1, pl);
  
  % Use MATLAB directly
  [pxx,f] = pwelch(a1.data.y, win.win, Nfft/2, Nfft, a1.data.fs);
  a3 = ao(f.', pxx.', ...
    plist('type', 'fsdata', 'xunits', 'Hz', 'name', 'Matlab pwelch'));
  
  % Plot
  iplot(a2, a3, plist('LineStyles', {'', '--'}))
  iplot(a2./a3)
  
  close all
end
