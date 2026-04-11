% Test ao.cohere functionality.
%
% M Hewitson 13-02-07
%
% $Id$
%
function test_ltpda_cohere()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  a1 = ao(pl);
  a2 = ao(pl);
  
  % Filter one time-series
  
  % Make a filter
  pl = plist('type', 'bandpass', 'fs', 1000, 'order', 3, 'fc', [50 250]);
  f2 = miir(pl);
  
  % filter the input data
  a3 = filter(a1, plist('filter', f2));
  
  % make some cross-power
  a4 = 5.*a3+a2;
  
  % Make coherence
  a8 = cohere(a4, a1, plist('Nfft', 2000));
  
  % Plot results and history
  
  iplot(a8, plist('YScales', 'lin'));
  
  % Reproduce from history
  a_out = rebuild(a8);
  b = a_out;
  
  iplot(b)
  
  close all
end

