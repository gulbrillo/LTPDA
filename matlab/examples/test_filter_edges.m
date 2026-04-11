% TEST_FILTER_EDGES tests if filter function correctly stores the state
% from one call to the next.
%
% M Hewitson 19-05-07
%
% $Id$
%
function test_filter_edges()
  
  
  fs = 1000;
  
  pl = plist('nsecs', 10, 'fs', fs, 'tsfcn', 'sin(2*pi*2.4*t)');
  a = ao(pl);
  
  % highpass
  pl = plist('type', 'highpass', 'fs', fs, 'fc', 60, 'order', 3);
  f2 = miir(pl);
  
  % split a into 2 segments
  as = split(a, plist('times', [0 5 5 10]));
  a1 = as(1);
  a2 = as(2);
  
  % filter first segment
  a1f = filter(a1, f2);
  % filter second segment
  a2f = filter(a2, a1f.procinfo.find('filter'));
  
  % plot
  iplot([a1f a2f], plist('Markers', {'o', 'o'}, 'XRanges', [4.98 5.02]));
  
  close all
end



