% Test AO constructor for TS function
%
% M Hewitson 02-04-07
%
% $Id$
%
function test_ao_tsfcn()
  
  
  pl = plist('nsecs', 10, 'fs', 100, 'tsfcn', 'sin(2*pi*2.4*t).*exp(-t.^.5/2)');
  a = ao(pl);
  iplot(a);
  
  close all
end
