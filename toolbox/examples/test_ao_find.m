% TEST_AO_FIND test the find function of AO class.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ao_find()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Make spectrum
  a1xx = psd(a1);
  
  % Select Times
  a1s = find(a1, 'x < 1', 'x > 0.1');
  a2s = find(a1, 'y > 1');
  
  [hf, ha, hl] = iplot([a1 a2s]);
  [hf, ha, hl] = iplot([a1 a1s a2s]);
  set(hl(2), 'Marker', 'o', 'LineStyle', 'None')
  
  
  % Select Frequencies
  a1xxs = select(a1xx, [1 2 3], [4 5 6], plist('samples', [7 8 9]));
  
  [hf, ha, hl] = iplot([a1xx a1xxs]);
  set(hl(2), 'Marker', 'o', 'LineStyle', 'None')
  
  close all
end
% END