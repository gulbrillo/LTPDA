% When the filter command is given a standard filter designed for a
% different sample rate than the input data, we should redesign the filter
% on the fly.  This can be done since the filter object contains the plist
% that was used to design it.
%
% M Hewitson 04-04-07
%
% $Id$
function test_miir_redesign()
  
  
  % Make a filter
  pl = plist('type', 'bandpass', 'fs', 1000, 'fc', [50 100], 'order', 3);
  f  = miir(pl)
  
  
  % Make test AOs
  nsecs = 10;
  fs    = 5000;
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Filter the input data
  a2 = filter(a1,plist('filter', f));
  
  % Plot time-series
  iplot(a1, a2)
  
  % Make PSDs of input and output
  nfft = 16384;
  w = specwin('Hanning', nfft);
  pl = plist('Win', w, 'Nfft', nfft);
  
  a3 = psd(a1, pl);
  a4 = psd(a2, pl);
  
  % Plot PSDs
  iplot([a3 a4])
  
  close all
end

% END

