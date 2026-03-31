% TEST_AO_UPSAMPLE tests upsample method of AO class.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ao_upsample()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 100;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t)');
  
  a1 = ao(pl);
  a1 = a1.setName('sine_wave');
  
  % Decimate
  a4 = upsample(a1, plist('N', 2));
  a5 = upsample(a1, plist('N', 3, 'Phase', 1));
  
  iplot([a1 a5 a4], plist('XRanges', [0 0.1]));
  
  
  % Rebuild from history
  a_out = rebuild(a5);
  
  iplot([a1 a_out], plist('XRanges', [0 0.1]));
  
  close all
end
% END
