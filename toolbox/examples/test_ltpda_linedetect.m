% TEST_LTPDA_LINEDETECT test script for ao.linedetect.
%
% M Hewitson 14-05-07
%
% $Id$
%
function test_ltpda_linedetect()
  
  
  % Make test AOs
  
  nsecs = 10000;
  fs    = 10;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*1.433*t) + 10*sin(2*pi*0.021*t) + randn(size(t))');
  x12 = ao(pl);
  
  % Make spectrum
  pl = plist('Nfft', round(1000*x12.data.fs'));
  x12xx = psd(x12, pl);
  
  % Detect lines
  pl   = plist('N', 100, 'bw', 256, 'hc', 0.9, 'thresh', 2.5);
  x12l = linedetect(x12xx, pl);
  
  % Plot
  ppl = plist('Markers', {'', 'o'}, 'LineStyles', {'', 'None'});
  iplot([x12xx x12l], ppl);
  
  
  %% Write an m-file from AO
  a_out = rebuild(x12l);
  
  iplot(a_out)
  
  close all
end
% END


