% Test ao.tfe functionality.
%
% M Hewitson 13-02-07
%
% $Id$
%
function test_ltpda_tfe()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Filter one time-series
  
  % Make a filter
  f1 = miir(plist('type', 'highpass', 'fc', 20, 'fs', fs));
  
  % Filter the input data
  a2 = filter(a1,plist('filter', f1));
  
  % Make TF from a1 to a2
  a4 = tfe(a1,a2, plist('Nfft', 1000));
  
  % Plot results and history
  b = a4;
  
  iplot(b);
  
  % Reproduce from history
  a_out = rebuild(b);
  
  iplot(a_out)
  
  close all
end

