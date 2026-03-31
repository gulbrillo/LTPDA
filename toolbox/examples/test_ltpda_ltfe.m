% TEST_LTPDA_LTFE test the ao.ltfe method.
%
% M Hewitson 23-05-07
%
% $Id$
%
function test_ltpda_ltfe()
  
  % Make test AO
  
  nsecs = 10000;
  fs    = 10;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  a1 = ao(pl);
  
  
  % Filter one time-series
  
  % Make a filter
  f1 = miir(plist('type', 'highpass', 'fc', 0.1));
  
  % Filter the input data
  a2 = filter(a1,plist('filter', f1));
  
  % Make a filter
  f1 = miir(plist('type', 'lowpass', 'fc', .03));
  
  % Filter the input data
  a3 = filter(a1,plist('filter', f1));
  
  
  % Split data
  pl    = plist('times', [10 a1.data.nsecs]);
  aoin  = split(a1, pl);
  aoout = split(a2, pl);
  aoout2 = split(a3, pl);
  
  % Make TF from a1 to a2
  
  pl = plist('Kdes', 1000, 'Jdes', 1000, 'Order', 1);
  
  % log TF estiamtes
  tfs = ltfe(aoin, aoout, pl);
  
  
  % Plot
  iplot(tfs)
  
  % Recreate from History
  a_out = rebuild(tfs);
  
  iplot(a_out)
  b = a_out;
  
  close all
end



% END
