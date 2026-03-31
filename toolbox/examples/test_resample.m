% Test resample function for AOs.
%
% M Hewitson 24-03-07
%
% $Id$
%
function test_resample()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  a1 = ao(pl);
  
  % Resample
  a2 = resample(a1, plist('fsout', 2000));
  a3 = resample(a1, plist('fsout', 500));
  
  % Plot
  iplot([a1 a2 a3]);
  utils.plottools.allxaxis(0, 0.1)
  
  close all
end




