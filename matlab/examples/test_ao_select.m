% TEST_AO_SELECT test the select function of AO class.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ao_select()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Make spectrum
  a1xx = psd(a1);
  
  % Select Times
  pl = plist('Markers', {'', 'o'}, 'LineStyles', {'', 'None'});
  a1s = select(a1, [10:100], [4 5 6], plist('samples', [2000:40:2300]));
  iplot([a1 a1s], pl);
  
  % Select Frequencies
  iplot(a1xx)
  a1xxs = select(a1xx, [1 2 3], [4 5 6], plist('samples', [7 8 9]));
  
  iplot([a1xx a1xxs], pl);
  
  close all
end
% END