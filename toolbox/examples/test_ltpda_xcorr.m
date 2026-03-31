% TEST_LTPDA_XCORR tests the cross-correlation function ltpda_xcorr.
%
% M Hewitson 19-06-07
%
% $Id$
%
function test_ltpda_xcorr()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist();
  pl.append('nsecs', nsecs);
  pl.append('fs', fs);
  pl.append('tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  pl.append('yunits', 'm');
  
  a1 = ao(pl);
  
  % Filter one time-series
  
  % Make a filter
  f1 = miir(plist('type', 'highpass', 'fc', 20, 'fs', fs, 'iunits', 'm', 'ounits', 'N'));
  
  % Filter the input data
  a2 = filter(a1, plist(param('filter', f1)));
  
  % Make X-correlation from a1 to a2
  a4 = xcorr(a1, a2, plist('Scale', 'coeff'));
  
  % Plot results and history
  iplot(a4);
  
  % Reproduce from history
  a_out = rebuild(a4);
  
  iplot(a_out)
  
  close all
end
