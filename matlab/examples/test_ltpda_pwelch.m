% Test the LTPDA wrapping of pwelch.
%
% M Hewitson
%
% 07-02-07
%
% $Id$
%
function test_ltpda_pwelch()
  
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', '(t.^2 - (t.^3)/10) + sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  
  % Make PSDs
  a3 = psd(a1);
  a4 = psd(a2);
  iplot(a3, a4)
  
  
  % Divide and plot history
  a5 = a3./a4;
  iplot(a5)
  
  % Reproduce from history
  a_out = rebuild(a5);
  
  iplot(a_out)
  
  close all
end
