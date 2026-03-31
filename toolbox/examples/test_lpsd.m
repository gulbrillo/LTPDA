% A test script for the AO implementation of lpsd.
%
% M Hewitson 02-02-07
%
% $Id$
%
function test_lpsd()
  
  
  % Make test AOs
  
  nsecs = 10000;
  fs    = 10;
  pl    = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  
  % Make LPSD of each
  
  % Window function
  w = specwin('Kaiser', 1000, 150);
  w = specwin('Hanning', 10);
  
  % parameter list for lpsd
  pl = plist('Kdes', 100, 'Jdes', 10000, 'Win', w, 'order', 1);
  
  % use lpsd
  tic
  a3 = lpsd(a1, pl);
  toc
  a4 = lpsd(a2, pl);
  
  iplot(a3)
  
  % add and plot
  a5 = a3+a4;
  iplot(a5*0.5)
  
  % Reproduce from history
  a_out = rebuild(a5);
  
  iplot(a_out)
  
  close all
end

