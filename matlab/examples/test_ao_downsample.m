% TEST_AO_DOWNSAMPLE tests downsample method of AO class.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ao_downsample()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 100;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*0.433*t)');
  
  a1 = ao(pl);
  a1.setName('sine_wave');
  
  % Decimate
  a2 = downsample(a1, plist('factor', 2));
  a3 = downsample(a1, plist('factor', 2, 'offset', 1));
  
  iplot(a1, a2, a3, plist('Markers', {'x', 'o', 's'}, 'XRanges', [0 0.1]));
  
  
  % Rebuild
  a_out = rebuild(a3);
  
  iplot(a_out)
  
  close all
end
% END
