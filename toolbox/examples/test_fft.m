% Test fft() operator for AOs.
%
% M Hewitson 19-04-07
%
% $Id$
%
function test_fft()
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 1000;  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  a1 = ao(pl);
  a1 = a1.setName;
  
  % Take plain one sided
  a2 = fft(a1,plist('type','plain'));
  iplot(abs(a2), plist('XScales', {'All', 'lin'}));
  
  % Take abs of one-sided
  a3 = abs(fft(a1,plist('type','one'))).^2;
  a4 = psd(a1, plist('Nfft', 10000, 'Win', specwin('Rectangular', 10000)));
  
  % Plot ratio
  rat = a3./a4;
  
  iplot(rat, plist('YScales', 'lin'))
  iplot(a3,a4)
  
  % Two-sided fft
  a5 = fft(a1, plist('type', 'two'));
  iplot(abs(a5), plist('XScales', {'All', 'lin'}));
  
  close all
end

% END