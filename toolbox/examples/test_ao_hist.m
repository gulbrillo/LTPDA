% TEST_AO_HIST tests the histogram function of the AO class.
%
% M Hewitson 24-05-07
%
% $Id$
%
function test_ao_hist()
  
  
  % Make some time-series data
  nsecs = 1000;
  fs    = 100;
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  a1 = ao(pl);
  
  % Make some frequency series data
  a2 = psd(a1);
  
  % Make some cdata
  a3 = ao(randn(nsecs*fs,1));
  
  % Make histograms
  s1 = a1 + a3;
  h1 = hist(a1,plist('N', 100));
  h2 = hist(a2,plist('N', 100));
  
  h3 = hist(a3,plist('N', 100));
  h4 = hist(a3,plist('X', h3.data.x));
  h5 = hist(s1,plist('N', 100));
  
  % Plot
  pl = plist('Function', 'stairs');
  iplot(h5, pl)
  
  iplot(h1, pl)
  iplot(h2, pl)
  iplot(h3, pl)
  iplot(h4, pl)
  iplot(h5, pl)
  
  
  close all
end
% END
