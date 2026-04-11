% Test ao.cohere functionality.
%
% M Hewitson 08-05-08
%
% $Id$
%
function test_ao_cohere()
  
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
  a3 = filter(a1,plist('filter', f1));
  
  % Make some cross-power
  a4 = a3 + a2;
  a4.setName;
  
  % Make cohere between a1 and a4
  Nfft = 1000*2;
  win  = specwin('Hanning', Nfft);
  pl = plist('Nfft', Nfft, 'Win', win, 'Order', 2, 'Type', 'ms');
  c1 = cohere(a1, a4, pl);
  
  % Use MATLAB directly
  [cxy, f] = mscohere(a1.data.y, a4.data.y, win.win, Nfft/2, Nfft, a1.fs);
  c2 = ao(f, cxy, ...
    plist('type', 'fsdata', 'xunits', 'Hz', 'yunits', '', 'name', 'Matlab mscohere'));
  
  % Plot
  iplot(c1, c2, plist('YScales', 'lin', 'LineStyles', {'', '--'}))
  
  % Check cohere(a1,a1) == 1
  c3 = cohere(a1, a1, pl);
  c4 = cohere(a4, a4, pl);
  
  iplot(simplifyYunits(c3, c4))
  
  close all
end
