% Test the constructor for miir objects.
%
% M Hewitson 11-02-07
%
% $Id$
%
function test_miir_class()
  
  
  % Example 1  - empty
  
  f = miir()
  
  % Example 2 - standard types
  
  % bandpass
  pl = plist('type', 'bandpass', 'fs', 1000, 'fc', [50 100], 'order', 3);
  f1 = miir(pl);
  
  % highpass
  pl = plist('type', 'highpass', 'fs', 1000, 'fc', 60, 'order', 3);
  f2 = miir(pl);
  
  
  % Plot response
  
  pl = plist('f1', 10, 'f2', 200);
  a1 = resp(f1, pl);
  a2 = resp(f2, pl);
  a3 = a2.*a1;
  a4 = a2./a1;
  
  iplot(a1, a2, a3, a4)
  
  close all
end





