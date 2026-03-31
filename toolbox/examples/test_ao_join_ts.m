% TEST_AO_JOIN_TS test then join method of AO class for tsdata objects.
%
% M Hewitson 03-06-07
%
% $Id$
%
function test_ao_join_ts()
  
  % Make some AOs
  
  nsecs = 10;
  fs    = 1;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a1.setName('a1');
  a1.setT0('2007-05-01 22:00:05');
  
  a2 = ao(pl);
  a2.setName('a2');
  a2.setT0('2007-05-01 22:00:00');
  
  a3 = ao(pl);
  a3.setName('a3');
  a3.setT0('2007-05-01 22:00:25');
  
  
  % Join
  aj = join(a1,a2,a3);
  
  % Plot
  iplot([a1 a2 a3 aj], plist('Markers', {'o', 'o', 'o', ''}));
  
  close all
end
% END
