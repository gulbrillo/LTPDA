% Test script for ao.lincom.
%
% M Hewitson 14-02-07
%
% $Id$
%
function test_ltpda_lincom()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  a3 = ao(pl);
  
  % Make linear combination
  
  b = lincom(a1, a2, a3, ao([1 2 3]));
  
  iplot(b)
  
  % Reproduce from history
  a_out = rebuild(b);
  
  iplot(a_out)
  
  close all
end


% END
