% Test script for ao.detrend
%
% M Hewitson, A Monsky 01-03-07
%
% $Id$
%
function test_ltpda_polydetrend()
  
  
  %% Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', '2e5*sin(2*pi*0.000433*t) + randn(size(t))');
  a1 = ao(pl);
  
  iplot(a1)
  
  % Polynomial detrend
  a2 = detrend(a1, plist('order', 3));
  iplot(a2)
  
  % Look at the polynomial
  a3 = a1-a2;
  iplot(a3)
  
  % Reproduce from history
  a_out = rebuild(a2);
  
  iplot(a_out)
  
  close all
end

