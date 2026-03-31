% TEST_LTPDA_NFEST tests the ltpda_nfest noise-floor estimator.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ltpda_nfest()
  
  
  nsecs = 10000;
  fs    = 10;
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*0.433*t) + 10*sin(2*pi*0.021*t) + randn(size(t))');
  x12 = ao(pl);
  
  % Make spectrum
  
  pl = plist('Nfft', '100*fs');
  x12xx = psd(x12, pl);
  
  % Make noise-floor estimate
  pl    = plist('width', 128);
  x12nf = smoother(x12xx, pl)
  
  % Plot
  iplot([x12xx x12nf])
  
  
  % Rebuild from history
  a_out = rebuild(x12nf);
  
  iplot(a_out)
  
  close all
end
% END

