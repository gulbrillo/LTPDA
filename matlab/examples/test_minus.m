% A test script for the AO minus.
%
% M Hewitson 16-03-07
%
% $Id$
%
function test_minus()
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  
  % add and plot
  a3  = a1-2;
  
  iplot(a3)
  
  
  % Reproduce from history
  a_out = rebuild(a3);
  
  iplot(a_out)
  
  close all
end

