% Test script for ao.lincom.
%
% M Hewitson 14-02-07
%
% $Id$
%
function test_lincom_cdata()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist();
  pl.append('nsecs', nsecs);
  pl.append('fs', fs);
  pl.append('tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  a3 = ao(pl);
  a4 = ao(pl);
  
  
  % Make a cdata AO with the coefficients in
  b  = ao([1 2 3]);
  
  %% Make linear combination
  c = lincom(a1, a2, a3, b);
  
  iplot(c)
  
  % Reproduce from history
  a_out = rebuild(c);
  
  iplot(a_out)
  
  close all
end
% END
