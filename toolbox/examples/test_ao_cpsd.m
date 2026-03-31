% Test ao.cpsd functionality.
%
% M Hewitson 08-05-08
%
% $Id$
%
function test_ao_cpsd()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist(...
    'nsecs', nsecs, ...
    'fs', fs, ...
    'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))', ...
    'yunits', 'K');
  
  a1 = ao(pl);
  a2 = ao(pl);
  
  % Filter one time-series
  
  % Make a filter
  pl = plist('type', 'bandpass', 'fs', 1000, 'order', 3, 'fc', [50 250]);
  f1 = miir(pl);
  
  % Filter the input data
  a3 = filter(a1, plist('filter', f1));
  
  % Make some cross-power
  a4 = 10.*a3 + a2;
  a4.setName;
  
  % Make CPSD from a1 to a4
  Nfft = 1000;
  win  = specwin('Hanning', Nfft);
  pl = plist('Nfft', Nfft, 'Win', win, 'Order', 2);
  c1 = cpsd(a1, a4, pl);
  
  % Use MATLAB directly
  [pxy, f] = cpsd(a1.data.y, a4.data.y, win.win, Nfft/2, Nfft, a1.fs);
  c2 = ao(f.', pxy.', ...
    plist('type', 'fsdata', 'xunits', 'Hz', 'yunits', a1.yunits * a4.yunits * unit('Hz^-1'), 'name', 'Matlab cpsd'));
  
  % Plot
  iplot(c1, c2, plist('LineStyles', {'', '--'}))
  iplot(simplifyYunits(c1 ./ c2))
  
  % Check cpsd(a1,a1) == psd(a1)
  c3 = cpsd(a1, a1, pl);
  c4 = psd(a1, pl);
  
  iplot(simplifyYunits(c3, c4))
  
  close all
end
