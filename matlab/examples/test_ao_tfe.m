% Test ao.tfe functionality.
%
% M Hewitson 13-02-07
%
% $Id$
%
function test_ao_tfe()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist(...
    'nsecs', nsecs, ...
    'fs', fs, ...
    'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))', ...
    'yunits', 'K');
  
  a1 = ao(pl);
  a1 = a1.setName;
  
  % Filter one time-series
  
  % Make a filter
  pl = plist('type', 'highpass', 'fc', 20, 'fs', fs, 'iunits', 'K', 'ounits', 'm');
  f1 = miir(pl);
  
  % Filter the input data
  a2 = filter(a1, plist('filter', f1));
  
  % Calculate TF from a1 to a2
  Nfft = 1000;
  win  = specwin('Hanning', Nfft);
  pl = plist('Nfft', Nfft, 'Win', win, 'Order', -1);
  t1 = tfe(a1, a2, pl);
  
  % Use MATLAB directly
  [txy, f] = tfestimate(a1.data.y, a2.data.y, win.win, Nfft/2, Nfft, a1.fs);
  t2 = ao(f.', txy.', ...
    plist('type', 'fsdata', 'xunits', t1.xunits, 'yunits', a2.yunits / a1.yunits, 'name', 'Matlab tfestimate'));
  
  % Plot
  iplot(t1, t2, plist('LineStyles', {'', '--'},'YErrU',{t1.dy,''}))

  % Check tfe(a1,a1) == 1
  t3 = tfe(a1, a1, pl);
  t4 = tfe(a2, a2, pl);
  
  iplot(simplifyYunits(t3, t4))
  
  close all
end
